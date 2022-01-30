# frozen_string_literal: true

class Middleman::Extensions::ExternalPipeline < ::Middleman::Extension
  self.supports_multiple_instances = true

  option :name, nil, 'The name of the pipeline', required: true
  option :command, nil, 'The command to initialize', required: true
  option :source, nil, 'Path to merge into sitemap', required: true
  option :latency, 0.25, 'Latency between refreshes of source'
  option :disable_background_execution, false, "Don't run the command in a separate background thread"
  option :ignore_exit_code, false, 'Ignore exit code for restart or stop of a command'
  option :manifest_json, nil, 'JSON file, which contain information about external assets paths'

  helpers do
    def external_pipeline_manifest_value(pipeline_name, path = [])
      return @cached_manifest[pipeline_name].dig(*path) if build? && @cached_manifest&.key?(pipeline_name)

      selected_extension = extensions[:external_pipeline].find { |_k, ep| ep.options[:name] == pipeline_name }&.last
      if selected_extension.nil?
        raise [
          "Couldn't find external pipeline with name #{pipeline_name}.",
          "Have only #{extensions[:external_pipeline].values.map { |ep| ep.options[:name] }.inspect}"
        ].join(' ')
      end

      manifest_json = selected_extension.options[:manifest_json]
      raise "Couldn't find manifest_json file at path #{manifest_json}" if manifest_json.nil? || !File.exist?(manifest_json)

      manifest_content = if build?
                           @cached_manifest ||= {}
                           @cached_manifest[pipeline_name] ||= JSON.parse(File.read(manifest_json))
                           @cached_manifest[pipeline_name]
                         else
                           JSON.parse(File.read(manifest_json)) # no caching for dev
                         end
      manifest_content.dig(*path)
    end

    def external_pipeline_javascript_tag(pipeline_name, path = [], options = {})
      content_tag(:script, nil, {
        src: external_pipeline_manifest_value(pipeline_name, path)
      }.update(options))
    end

    def external_pipeline_stylesheet_tag(pipeline_name, path = [], options = {})
      tag(:link, {
        href: external_pipeline_manifest_value(pipeline_name, path),
        rel: 'stylesheet'
      }.update(options))
    end
  end

  def initialize(app, options_hash = ::Middleman::EMPTY_HASH, &block)
    super

    return if app.mode?(:config)

    require 'servolux'
    require 'fileutils'

    source_path = File.expand_path(options[:source], app.root)

    # Make sure it exists, or `listen` will explode.
    ::FileUtils.mkdir_p(source_path)

    @watcher = app.files.watch :source,
                               path: source_path,
                               latency: options[:latency],
                               frontmatter: false

    @current_thread = nil
    app.reload(&method(:reload!))

    logger.info "== Executing: `#{options[:command]}`"

    if app.build? || options[:disable_background_execution]
      watch_command!(false)

      @watcher.poll_once!
    else
      watch_command!(true)
    end
  end

  def reload!
    return unless @current_thread

    logger.info "== Stopping: `#{options[:command]}`"

    @current_thread.stop
    @current_thread = nil
  end

  def watch_command!(async)
    @current_thread = ::Servolux::Child.new(
      command: options[:command],
      suspend: 2
    )

    @current_thread.start

    watch_thread = Thread.new do
      buf = @current_thread.io.gets

      while buf
        without_newline = buf.sub(/\n$/, '')
        logger.info "== External: #{without_newline}" unless without_newline.empty?
        buf = @current_thread.io.gets
      end

      @current_thread.wait

      if !options[:ignore_exit_code] && !@current_thread.exitstatus.nil? && @current_thread.exitstatus != 0
        logger.error '== External: Command failed with non-zero exit status'
        exit(1)
      end
    end

    watch_thread.join unless async
  rescue ::Errno::ENOENT => e
    logger.error "== External: Command failed with message: #{e.message}"
    exit(1)
  end

  private

  def print_command(stdout)
    buf = stdout.gets

    while buf
      without_newline = buf.sub(/\n$/, '')
      logger.info "== External: #{without_newline}" unless without_newline.empty?
      buf = stdout.gets
    end
  end
end
