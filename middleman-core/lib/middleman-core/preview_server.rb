require 'webrick'
require 'middleman-core/meta_pages'
require 'middleman-core/logger'
require 'middleman-core/rack'

# rubocop:disable GlobalVars
module Middleman
  module PreviewServer
    class << self
      extend Forwardable

      attr_reader :app, :host, :port
      def_delegator :app, :logger

      # Start an instance of Middleman::Application
      # @return [void]
      def start(opts={})
        @options = opts

        mount_instance(new_app)
        logger.info "== The Middleman is standing watch at #{uri}"
        logger.info "== Inspect your site configuration at #{uri + '__middleman'}"

        @initialized ||= false
        return if @initialized
        @initialized = true

        register_signal_handlers

        # Save the last-used @options so it may be re-used when
        # reloading later on.
        ::Middleman::Profiling.report('server_start')

        loop do
          @webrick.start

          # $mm_shutdown is set by the signal handler
          if $mm_shutdown
            shutdown
            exit
          elsif $mm_reload
            $mm_reload = false
            reload
          end
        end
      end

      # Detach the current Middleman::Application instance
      # @return [void]
      def stop
        begin
          logger.info '== The Middleman is shutting down'
        rescue
          # if the user closed their terminal STDOUT/STDERR won't exist
        end

        unmount_instance
      end

      # Simply stop, then start the server
      # @return [void]
      def reload
        logger.info '== The Middleman is reloading'

        begin
          app = new_app
        rescue => e
          logger.error "Error reloading Middleman: #{e}\n#{e.backtrace.join("\n")}"
          logger.info '== The Middleman is still running the application from before the error'
          return
        end

        unmount_instance
        mount_instance(app)

        logger.info '== The Middleman has reloaded'
      end

      # Stop the current instance, exit Webrick
      # @return [void]
      def shutdown
        stop
        @webrick.shutdown
      end

      private

      def new_app
        opts = @options.dup

        ::Middleman::Logger.singleton(
          opts[:debug] ? 0 : 1,
          opts[:instrumenting] || false
        )

        app = ::Middleman::Application.new do
          config[:environment] = opts[:environment].to_sym if opts[:environment]
          config[:watcher_disable] = opts[:disable_watcher]
          config[:watcher_force_polling] = opts[:force_polling]
          config[:watcher_latency] = opts[:latency]

          config[:host] = opts[:host] if opts[:host]
          config[:port] = opts[:port] if opts[:port]

          ready do
            match_against = [
              %r{^config\.rb$},
              %r{^environments/[^\.](.*)\.rb$},
              %r{^lib/[^\.](.*)\.rb$},
              %r{^#{@app.config[:helpers_dir]}/[^\.](.*)\.rb$}
            ]

            # config.rb
            files.watch :reload,
                        path: root,
                        only: match_against
          end
        end

        @host = app.config[:host]
        @port = app.config[:port]

        app.files.on_change :reload do
          $mm_reload = true
          @webrick.stop
        end

        # Add in the meta pages application
        meta_app = Middleman::MetaPages::Application.new(app)
        app.map '/__middleman' do
          run meta_app
        end

        app
      end

      # Trap some interupt signals and shut down smoothly
      # @return [void]
      def register_signal_handlers
        %w(INT HUP TERM QUIT).each do |sig|
          next unless Signal.list[sig]

          Signal.trap(sig) do
            # Do as little work as possible in the signal context
            $mm_shutdown = true

            @webrick.stop
          end
        end
      end

      # Initialize webrick
      # @return [void]
      def setup_webrick(is_logging)
        http_opts = {
          BindAddress: host,
          Port: port,
          AccessLog: [],
          DoNotReverseLookup: true
        }

        if is_logging
          http_opts[:Logger] = FilteredWebrickLog.new
        else
          http_opts[:Logger] = ::WEBrick::Log.new(nil, 0)
        end

        begin
          ::WEBrick::HTTPServer.new(http_opts)
        rescue Errno::EADDRINUSE
          logger.error "== Port #{port} is unavailable. Either close the instance of Middleman already running on #{port} or start this Middleman on a new port with: --port=#{port.to_i + 1}"
          exit(1)
        end
      end

      # Attach a new Middleman::Application instance
      # @param [Middleman::Application] app
      # @return [void]
      def mount_instance(app)
        @app = app

        @webrick ||= setup_webrick(@options[:debug] || false)

        rack_app = ::Middleman::Rack.new(@app).to_app
        @webrick.mount '/', ::Rack::Handler::WEBrick, rack_app
      end

      # Detach the current Middleman::Application instance
      # @return [void]
      def unmount_instance
        @webrick.unmount '/'

        @app.shutdown!

        @app = nil
      end

      # Returns the URI the preview server will run on
      # @return [URI]
      def uri
        host = (@host == '0.0.0.0') ? 'localhost' : @host
        URI("http://#{host}:#{@port}")
      end
    end

    class FilteredWebrickLog < ::WEBrick::Log
      def log(level, data)
        super(level, data) unless data =~ %r{Could not determine content-length of response body.}
      end
    end
  end
end
