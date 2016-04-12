class Middleman::Extensions::ExternalPipeline < ::Middleman::Extension
  self.supports_multiple_instances = true

  option :name, nil, 'The name of the pipeline', required: true
  option :command, nil, 'The command to initialize', required: true
  option :source, nil, 'Path to merge into sitemap', required: true
  option :latency, 0.25, 'Latency between refreshes of source'
  option :disable_background_execution, false, "Don't run the command in a separate background thread"

  def initialize(app, config={}, &block)
    super

    return if app.mode?(:config)

    require 'servolux'
    require 'thread'
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
    if @current_thread
      logger.info "== Stopping: `#{options[:command]}`"

      @current_thread.stop
      @current_thread = nil
    end
  end

  def watch_command!(async)
    @current_thread = ::Servolux::Child.new(
      command: options[:command],
      suspend: 2
    )

    @current_thread.start

    watch_thread = Thread.new do
      while buf = @current_thread.io.gets
        without_newline = buf.sub(/\n$/, '')
        logger.info "== External: #{without_newline}" unless without_newline.empty?
      end

      @current_thread.wait

      if !@current_thread.exitstatus.nil? && @current_thread.exitstatus != 0
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
    while buf = stdout.gets
      without_newline = buf.sub(/\n$/, '')
      logger.info "== External: #{without_newline}" unless without_newline.empty?
    end
  end
end
