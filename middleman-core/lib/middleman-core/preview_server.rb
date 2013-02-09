require "webrick"

module Middleman
  module PreviewServer

    DEFAULT_PORT = 4567

    class << self
      attr_reader :app, :host, :port
      delegate :logger, :to => :app

      # Start an instance of Middleman::Application
      # @return [void]
      def start(opts={})
        @options = opts
        @host = @options[:host] || Socket.gethostname
        @port = @options[:port] || DEFAULT_PORT

        mount_instance
        logger.info "== The Middleman is standing watch at http://#{host}:#{port}"

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

        if @listener
          @listener.stop
          @listener = nil
        end
        unmount_instance
      end

      # Simply stop, then start the server
      # @return [void]
      def reload
        logger.info "== The Middleman is reloading"

        unmount_instance
        mount_instance

        logger.info "== The Middleman is standing watch at http://#{host}:#{port}"
      end

      # Stop the current instance, exit Webrick
      # @return [void]
      def shutdown
        stop
        @webrick.shutdown
      end

    private
      def new_app
        opts = @options
        @app =::Middleman::Application.server.inst do
          if opts[:environment]
            set :environment, opts[:environment].to_sym
          end

          logger(opts[:debug] ? 0 : 1, opts[:instrumenting] || false)
        end
      end

      def start_file_watcher
        return if @options[:disable_watcher]

        first_run = !@listener

        if first_run
          # Watcher Library
          require "listen"
          @listener = Listen.to(Dir.pwd, :relative_paths => true, :force_polling => @options[:force_polling])
        end

        @listener.change do |modified, added, removed|
          added_and_modified = (modified + added)

          # See if the changed file is config.rb or lib/*.rb
          if needs_to_reload?(added_and_modified) || needs_to_reload?(removed)
            reload
          else
            added_and_modified.each do |path|
              app.files.did_change(path)
            end

            removed.each do |path|
              app.files.did_delete(path)
            end
          end
        end

        # Don't block this thread
        @listener.start(false) if first_run
      end

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
      def setup_webrick(is_logging)
        http_opts = {
          :BindAddress => host,
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

      # Attach a new Middleman::Application instance
      # @param [Middleman::Application] app
      # @return [void]
      def mount_instance
        @app = new_app

        @webrick ||= setup_webrick(@options[:debug] || false)

        start_file_watcher

        @webrick.mount "/", ::Rack::Handler::WEBrick, app.class.to_rack_app
      end

      # Detach the current Middleman::Application instance
      # @return [void]
      def unmount_instance
        @webrick.unmount "/"
        @app = nil
      end

      # Whether the passed files are config.rb, lib/*.rb or helpers
      # @param [Array<String>] paths Array of paths to check
      # @return [Boolean] Whether the server needs to reload
      def needs_to_reload?(paths)
        match_against = [
          %r{^config\.rb},
          %r{^lib/^[^\.](.*)\.rb$},
          %r{^helpers/^[^\.](.*)_helper\.rb$}
        ]

        if @options[:reload_paths]
          @options[:reload_paths].split(',').each do |part|
            match_against << %r{^#{part}}
          end
        end

        paths.any? do |path|
          match_against.any? do |matcher|
            path =~ matcher
          end
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
