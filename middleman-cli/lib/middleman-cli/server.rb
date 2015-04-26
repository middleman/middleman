# CLI Module
module Middleman::Cli
  # Server thor task
  class Server < Thor::Group
    check_unknown_options!

    class_option :environment,
                 aliases: '-e',
                 default: ENV['MM_ENV'] || ENV['RACK_ENV'] || 'development',
                 desc: 'The environment Middleman will run under'
    class_option :host,
                 type: :string,
                 aliases: '-h',
                 desc: 'Bind to HOST address'
    class_option :port,
                 aliases: '-p',
                 desc: 'The port Middleman will listen on'
    class_option :verbose,
                 type: :boolean,
                 default: false,
                 desc: 'Print debug messages'
    class_option :instrument,
                 type: :string,
                 default: false,
                 desc: 'Print instrument messages'
    class_option :disable_watcher,
                 type: :boolean,
                 default: false,
                 desc: 'Disable the file change and delete watcher process'
    class_option :profile,
                 type: :boolean,
                 default: false,
                 desc: 'Generate profiling report for server startup'
    class_option :force_polling,
                 type: :boolean,
                 default: false,
                 desc: 'Force file watcher into polling mode'
    class_option :latency,
                 type: :numeric,
                 aliases: '-l',
                 default: 0.5,
                 desc: 'Set file watcher latency, in seconds'

    # Start the server
    def server
      require 'middleman-core'
      require 'middleman-core/preview_server'

      unless ENV['MM_ROOT']
        puts '== Could not find a Middleman project config.rb'
        exit
      end

      params = {
        port: options['port'],
        host: options['host'],
        environment: options['environment'],
        debug: options['verbose'],
        instrumenting: options['instrument'],
        disable_watcher: options['disable_watcher'],
        reload_paths: options['reload_paths'],
        force_polling: options['force_polling'],
        latency: options['latency']
      }

      puts '== The Middleman is loading'
      ::Middleman::PreviewServer.start(params)
    end

    # Add to CLI
    Base.register(self, 'server', 'server [options]', 'Start the preview server')

    # Map "s" to "server"
    Base.map('s' => 'server')
  end
end
