class Middleman::Extensions::ExternalPipeline < ::Middleman::Extension
  self.supports_multiple_instances = true

  option :name, nil, 'The name of the pipeline', required: true
  option :command, nil, 'The command to initialize', required: true
  option :source, nil, 'Path to merge into sitemap', required: true
  option :latency, 0.25, 'Latency between refreshes of source'
  option :disable_background_execution, false, "Don't run the command in a separate background thread"

  def initialize(app, config={}, &block)
    super

    require 'thread'

    @watcher = app.files.watch :source,
                               path: File.expand_path(options[:source], app.root),
                               latency: options[:latency]
  end

  def ready
    logger.info "== Executing: `#{options[:command]}`"

    if app.build? || options[:disable_background_execution]
      watch_command!
    else
      ::Thread.new { watch_command! }
    end
  end

  def watch_command!
    ::IO.popen(options[:command], 'r') do |pipe|
      while buf = pipe.gets
        without_newline = buf.sub(/\n$/, '')
        logger.info "== External: #{without_newline}" if without_newline.length > 0
      end
    end

    @watcher.poll_once!
  rescue ::Errno::ENOENT => e
    logger.error "== External: Command failed with message: #{e.message}"
    exit(1)
  end
end
