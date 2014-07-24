class Middleman::Extensions::ExternalPipeline < ::Middleman::Extension
  self.supports_multiple_instances = true

  option :name, nil, 'The name of the pipeline', required: true
  option :command, nil, 'The command to initialize', required: true
  option :source, nil, 'Path to merge into sitemap', required: true
  option :latency, 0.25, 'Latency between refreshes of source'

  def initialize(app, config={}, &block)
    super

    require 'thread'

    app.files.watch :source,
                    path: File.expand_path(options[:source], app.root),
                    latency: options[:latency]
  end

  def after_configuration
    if app.build?
      logger.info "== Executing: `#{options[:command]}`"
      watch_command!
    else
      logger.debug "== Executing: `#{options[:command]}`"
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
  end
end
