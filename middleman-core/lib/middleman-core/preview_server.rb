require "webrick"
require "middleman-core/rack/controller"

module Middleman
  module PreviewServer

    DEFAULT_PORT = 4567

    class << self
      attr_reader :rack_app
      delegate :logger, :to => :rack_app
      
      # Start an instance of Middleman::Application
      # @return [void]
      def start(options={})
        options[:watcher] = !options[:"disable-watcher"]
        port = options[:post] || DEFAULT_PORT

        @rack_app = ::Middleman::Rack::Controller.new(options) do
          if options[:environment]
            set :environment, options[:environment].to_sym
          end
          
          logger(options[:debug] ? 0 : 1, options[:instrumenting] || false)
        end

        logger.info "== The Middleman is standing watch on port #{port}"

        @webrick ||= begin
          w = setup_webrick(
            options[:host]  || "0.0.0.0",
            port,
            options[:debug] || false
          )
          w.mount "/", ::Rack::Handler::WEBrick, @rack_app
          w
        end
        
        @initialized ||= false
        unless @initialized
          @initialized = true

          register_signal_handlers

          # Save the last-used @options so it may be re-used when
          # reloading later on.
          ::Middleman::Profiling.report("server_start")

          @webrick.start
        end
      end

      # Detach the current Middleman::Application instance
      # @return [void]
      def stop
        begin
          logger.info "== The Middleman is shutting down"
        rescue
          # if the user closed their terminal STDOUT/STDERR won't exist
        end
      end

      # Stop the current instance, exit Webrick
      # @return [void]
      def shutdown
        stop
        @webrick.shutdown
      end

    private

      # Trap some interupt signals and shut down smoothly
      # @return [void]
      def register_signal_handlers
        %w(INT HUP TERM QUIT).each do |sig|
          if Signal.list[sig]
            Signal.trap(sig) do
              shutdown
              exit
            end
          end
        end
      end

      # Initialize webrick
      # @return [void]
      def setup_webrick(host, port, is_logging)
        @host = host

        http_opts = {
          :BindAddress => @host,
          :Port        => port,
          :AccessLog   => []
        }

        if is_logging
          http_opts[:Logger] = FilteredWebrickLog.new
        else
          http_opts[:Logger] = ::WEBrick::Log.new(nil, 0)
        end

        begin
          ::WEBrick::HTTPServer.new(http_opts)
        rescue Errno::EADDRINUSE => e
          logger.error "== Port #{port} is unavailable. Either close the instance of Middleman already running on #{port} or start this Middleman on a new port with: --port=#{port.to_i+1}"
          exit(1)
        end
      end
    end

    class FilteredWebrickLog < ::WEBrick::Log
      def log(level, data)
        unless data =~ %r{Could not determine content-length of response body.}
          super(level, data)
        end
      end
    end
  end
end
