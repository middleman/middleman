require "webrick"

module Middleman

  WINDOWS = !!(RUBY_PLATFORM =~ /(mingw|bccwin|wince|mswin32)/i) unless const_defined?(:WINDOWS)

  module PreviewServer

    DEFAULT_PORT = 4567

    class << self
      attr_reader :app
      delegate :logger, :to => :app

      # Start an instance of Middleman::Application
      # @return [void]
      def start(options={})
        @app = ::Middleman::Application.server.inst do
          if options[:environment]
            set :environment, options[:environment].to_sym
          end

          logger(options[:debug] ? 0 : 1, options[:instrumenting] || false)
        end

        port = options[:port] || DEFAULT_PORT

        logger.info "== The Middleman is standing watch on port #{port}"

        @webrick ||= setup_webrick(
          options[:host]  || "0.0.0.0",
          port,
          options[:debug] || false
        )

        mount_instance(app)

        start_file_watcher unless options[:"disable-watcher"]

        @initialized ||= false
        unless @initialized
          @initialized = true

          register_signal_handlers unless ::Middleman::WINDOWS

          # Save the last-used options so it may be re-used when
          # reloading later on.
          @last_options = options
          ::Middleman::Profiling.report("server_start")

          @webrick.start
        end
      end

      # Detach the current Middleman::Application instance
      # @return [void]
      def stop
        logger.info "== The Middleman is shutting down"
        if @listener
          @listener.stop
          @listener = nil
        end
        unmount_instance
      end

      # Simply stop, then start the server
      # @return [void]
      def reload
        stop
        start @last_options
      end

      # Stop the current instance, exit Webrick
      # @return [void]
      def shutdown
        stop
        @webrick.shutdown
      end

    private

      def start_file_watcher
        # Watcher Library
        require "listen"

        return if @listener

        @listener = Listen.to(Dir.pwd, :relative_paths => true)

        @listener.change do |modified, added, removed|
          added_and_modified = (modified + added)

          unless added_and_modified.empty?
            # See if the changed file is config.rb or lib/*.rb
            if needs_to_reload?(added_and_modified)
              reload
              return
            end

            # Otherwise forward to Middleman
            added_and_modified.each do |path|
              @app.files.did_change(path)
            end
          end

          unless removed.empty?
            # See if the changed file is config.rb or lib/*.rb
            if needs_to_reload?(removed)
              reload
              return
            end

            # Otherwise forward to Middleman
            removed.each do |path|
              @app.files.did_delete(path)
            end
          end
        end

        # Don't block this thread
        @listener.start(false)
      end

      # Trap the interupt signal and shut down smoothly
      # @return [void]
      def register_signal_handlers
        trap("INT")  { shutdown }
        trap("TERM") { shutdown }
        trap("QUIT") { shutdown }
      end

      # Initialize webrick
      # @return [void]
      def setup_webrick(host, port, is_logging)
        @host = host
        @port = port

        http_opts = {
          :BindAddress => @host,
          :Port        => @port,
          :AccessLog   => []
        }

        if is_logging
          http_opts[:Logger] = FilteredWebrickLog.new
        else
          http_opts[:Logger] = ::WEBrick::Log.new(nil, 0)
        end

        ::WEBrick::HTTPServer.new(http_opts)
      end

      # Attach a new Middleman::Application instance
      # @param [Middleman::Application] app
      # @return [void]
      def mount_instance(app)
        @app = app
        @webrick.mount "/", ::Rack::Handler::WEBrick, @app.class.to_rack_app
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
        paths.any? do |path|
          path.match(%{^config\.rb}) || path.match(%r{^lib/^[^\.](.*)\.rb$}) || path.match(%r{^helpers/^[^\.](.*)_helper\.rb$})
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
