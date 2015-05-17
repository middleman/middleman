# CLI Module
module Middleman::Cli
  # Server thor task
  class Server < Thor
    check_unknown_options!

    namespace :server

    desc 'server [options]', 'Start the preview server'
    method_option :environment,
                  aliases: '-e',
                  default: ENV['MM_ENV'] || ENV['RACK_ENV'] || 'development',
                  desc: 'The environment Middleman will run under'
    method_option :port,
                  aliases: '-p',
                  desc: 'The port Middleman will listen on'
    method_option :host,
                  aliases: '-h',
                  desc: 'The host name Middleman will use'
    method_option :https,
                  type: :boolean,
                  desc: 'Serve the preview server over SSL/TLS'
    method_option :ssl_certificate,
                  desc: 'Path to an X.509 certificate to use for the preview server'
    method_option :ssl_private_key,
                  desc: "Path to an RSA private key for the preview server's certificate"
    method_option :verbose,
                  type: :boolean,
                  default: false,
                  desc: 'Print debug messages'
    method_option :instrument,
                  type: :string,
                  default: false,
                  desc: 'Print instrument messages'
    method_option :disable_watcher,
                  type: :boolean,
                  default: false,
                  desc: 'Disable the file change and delete watcher process'
    method_option :profile,
                  type: :boolean,
                  default: false,
                  desc: 'Generate profiling report for server startup'
    method_option :reload_paths,
                  type: :string,
                  default: false,
                  desc: 'Additional paths to auto-reload when files change'
    method_option :force_polling,
                  type: :boolean,
                  default: false,
                  desc: 'Force file watcher into polling mode'
    method_option :latency,
                  type: :numeric,
                  aliases: '-l',
                  default: 0.25,
                  desc: 'Set file watcher latency, in seconds'

    # Start the server
    def server
      require 'middleman-core'
      require 'middleman-core/preview_server'

      unless ENV['MM_ROOT']
        puts '== Could not find a Middleman project config.rb'
        puts '== Treating directory as a static site to be served'
        ENV['MM_ROOT'] = ::Middleman::Util.current_directory
        ENV['MM_SOURCE'] = ''
      end

      params = {
        port: options['port'],
        https: options['https'],
        host: options['host'],
        ssl_certificate: options['ssl_certificate'],
        ssl_private_key: options['ssl_private_key'],
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
  end

  def self.exit_on_failure?
    true
  end

  # Map "s" to "server"
  Base.map('s' => 'server')
end
