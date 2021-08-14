# frozen_string_literal: true

require 'openssl'
require 'middleman-core/meta_pages'
require 'middleman-core/logger'
require 'middleman-core/rack'
require 'middleman-core/preview_server/server_information'
require 'middleman-core/preview_server/server_url'
require 'middleman-core/preview_server/server_information_callback_proxy'
require 'middleman-core/preview_server/servers/webrick'

module Middleman
  class PreviewServer
    class << self
      extend Forwardable

      attr_reader :app, :web_server, :ssl_certificate, :ssl_private_key, :environment, :server_information

      # Start an instance of Middleman::Application
      # @return [void]
      def start(options_hash = ::Middleman::EMPTY_HASH, cli_options_hash = ::Middleman::EMPTY_HASH)
        # Do not buffer output, otherwise testing of output does not work
        $stdout.sync = true
        $stderr.sync = true

        @options = options_hash
        @cli_options = cli_options_hash
        @server_information = ServerInformation.new
        @server_information.https = (@options[:https] == true)

        # New app evaluates the middleman configuration. Since this can be
        # invalid as well, we need to evaluate the configuration BEFORE
        # checking for validity
        app = initialize_new_app

        # And now comes the check
        unless server_information.valid?
          warn %(== Running Middleman failed: #{server_information.reason}. Please fix that and try again.)
          exit 1
        end

        logger.debug %(== Server information is provided by #{server_information.handler})
        logger.debug %(== The Middleman is running in "#{environment}" environment)
        logger.debug format('== The Middleman preview server is bound to %<url>s', url: ServerUrl.new(hosts: server_information.listeners, port: server_information.port, https: server_information.https?).to_bind_addresses.join(', '))
        logger.info format('== View your site at %<url>s', url: ServerUrl.new(hosts: server_information.site_addresses, port: server_information.port, https: server_information.https?).to_urls.join(', '))
        logger.info format('== Inspect your site configuration at %<url>s', url: ServerUrl.new(hosts: server_information.site_addresses, port: server_information.port, https: server_information.https?).to_config_urls.join(', '))

        @initialized ||= false
        return if @initialized

        @initialized = true

        # Save the last-used @options so it may be re-used when
        # reloading later on.
        ::Middleman::Profiling.report('server_start')

        app.execute_callbacks(:before_server, [ServerInformationCallbackProxy.new(server_information)])

        if @options[:daemon]
          # To output the child PID, let's make preview server a daemon by hand
          child_pid = fork

          if child_pid
            logger.info "== Middleman preview server is running in background with PID #{child_pid}"
            Process.detach child_pid
            exit 0
          else
            $stdout.reopen('/dev/null', 'w')
            $stderr.reopen('/dev/null', 'w')
            $stdin.reopen('/dev/null', 'r')
          end
        end

        signals_thread = stop_on_exit_thread

        start_webserver(app)

        signals_thread.join # wait after reload for real exit by signals
      end

      def stop_on_exit_thread
        signals_queue = Queue.new

        %w[INT HUP TERM QUIT].each do |sig|
          next unless Signal.list[sig]

          Signal.trap(sig) do
            signals_queue << sig # send to queue signal
          end
        end

        Thread.new do
          signals_queue.pop # waiting for kill signal
          stop # stop web server and app
        end
      end

      # Stop web server
      # @return [void]
      def stop
        begin
          logger.info '== The Middleman is shutting down'
        rescue StandardError
          # if the user closed their terminal STDOUT/STDERR won't exist
        end

        stop_webserver
      end

      # Simply stop, then start the server
      # @return [void]
      def reload
        logger.info '== The Middleman is reloading'

        app.execute_callbacks(:reload)

        begin
          new_app = initialize_new_app
        rescue StandardError => e
          warn "Error reloading Middleman: #{e}\n#{e.backtrace.join("\n")}"
          logger.info '== The Middleman is still running the application from before the error'
          return
        end

        stop_webserver

        logger.info '== The Middleman has reloaded'

        start_webserver(new_app)
      end

      # Stop the current instance
      # @return [void]
      def shutdown
        stop
      end

      private

      def logger
        @logger ||= Logger.new(@options[:debug] ? :debug : :info)
      end

      def initialize_new_app
        opts = @options.dup
        cli_options = @cli_options.dup

        ::Middleman::Logger.singleton(
          opts[:debug] ? 0 : 1,
          opts[:instrumenting] || false
        )

        reload_queue = Queue.new

        app = ::Middleman::Application.new do
          config[:cli_options] = cli_options.each_with_object({}) do |(k, v), sum|
            sum[k] = v
          end

          ready do
            unless config[:watcher_disable]
              match_against = [
                /^config\.rb$/,
                %r{^environments/[^\.](.*)\.rb$},
                %r{^lib/[^\.](.*)\.rb$},
                %r{^#{config[:helpers_dir]}/[^\.](.*)\.rb$}
              ]

              # config.rb
              watcher = files.watch :reload,
                                    path: root,
                                    only: match_against

              # Hack around bower_components in root.
              watcher.listener.ignore(/^bower_components/)

              # Hack around node_modules in root.
              watcher.listener.ignore(/^node_modules/)

              # Hack around sass cache in root.
              watcher.listener.ignore(/^\.sass-cache/)

              # Hack around bundler cache in root.
              watcher.listener.ignore(%r{^vendor/bundle})
            end
          end
        end

        # store configured port to make a check later on possible
        configured_port = possible_from_cli(:port, app.config)

        # Use configuration values to set `bind_address` etc. in
        # `server_information`
        server_information.use(bind_address: possible_from_cli(:bind_address, app.config),
                               port: possible_from_cli(:port, app.config),
                               server_name: possible_from_cli(:server_name, app.config),
                               https: possible_from_cli(:https, app.config))

        unless server_information.port == configured_port
          logger.warn format(
            '== The Middleman uses a different port "%<new_port>s" then the configured one "%<old_port>s" because some other server is listening on that port.',
            new_port: server_information.port,
            old_port: configured_port
          )
        end

        @environment = possible_from_cli(:environment, app.config)

        @ssl_certificate = possible_from_cli(:ssl_certificate, app.config)
        @ssl_private_key = possible_from_cli(:ssl_private_key, app.config)

        app.files.on_change :reload do
          reload_queue << true
        end

        Thread.new do
          reload_queue.pop # wait for reload signal
          reload
        end

        # Add in the meta pages application
        meta_app = Middleman::MetaPages::Application.new(app)
        app.map '/__middleman' do |rack|
          rack.run meta_app
        end

        app
      end

      def possible_from_cli(key, config)
        @cli_options[key] || config[key]
      end

      # Start web server and app
      # @param [Middleman::Application] app
      # @return [void]
      def start_webserver(app)
        @app = app

        @web_server = Servers::Webrick.new(
          ::Middleman::Rack.new(app).to_app,
          server_information,
          @options[:debug] || false
        )
        @web_server.start
      end

      # Stop web server and app
      # @return [void]
      def stop_webserver
        web_server.shutdown!
        app.shutdown!

        @web_server = nil
        @app = nil
      end
    end
  end
end
