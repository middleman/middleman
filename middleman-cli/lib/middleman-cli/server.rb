# CLI Module
module Middleman::Cli
  # Server thor task
  class Server < Thor::Group
    check_unknown_options!

    class_option :environment,
                 aliases: '-e'
    class_option :port,
                 aliases: '-p'
    class_option :server_name,
                 aliases: '-s'
    class_option :bind_address,
                 aliases: '-b'
    class_option :verbose,
                 type: :boolean,
                 default: false,
                 desc: 'Print debug messages'
    class_option :instrument,
                 type: :boolean,
                 default: false,
                 desc: 'Print instrument messages'
    class_option :profile,
                 type: :boolean,
                 default: false,
                 desc: 'Generate profiling report for server startup'
    class_option :daemon,
                 type: :boolean,
                 aliases: '-d',
                 default: false,
                 desc: 'Daemonize preview server'

    Middleman::Cli.import_config(self)

    # Start the server
    def server
      require 'middleman-core'
      require 'middleman-core/preview_server'

      unless ENV['MM_ROOT']
        puts '== Could not find a Middleman project config.rb'
        exit
      end

      params = {
        debug: options['verbose'],
        instrumenting: options['instrument'],
        reload_paths: options['reload_paths'],
        daemon: options['daemon']
      }

      puts '== The Middleman is loading'
      ::Middleman::PreviewServer.start(params, options)
    end

    # Add to CLI
    Base.register(self, 'server', 'server [options]', 'Start the preview server')

    # Map "s" to "server"
    Base.map('s' => 'server')
  end
end
