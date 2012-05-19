module Middleman
  
  WINDOWS = !!(RUBY_PLATFORM =~ /(mingw|bccwin|wince|mswin32)/i) unless const_defined?(:WINDOWS)

  module PreviewServer
    
    DEFAULT_PORT = 4567
    
    class << self
      
      # Start an instance of Middleman::Application
      # @return [void]
      def start(options={})
        require "webrick"
        
        @first_run ||= true
        
        app = ::Middleman::Application.server.inst do
          if options[:environment]
            set :environment, options[:environment]
          end
          
          if options[:debug]
            set :logging, true
          end
        end
    
        puts "== The Middleman is standing watch on port #{options[:port]||4567}"
          
        @webrick_is_running ||= false
        @webrick ||= setup_webrick(
          options[:host]  || "0.0.0.0",
          options[:port]  || DEFAULT_PORT,
          options[:debug] || false
        )
        
        mount_instance(app)
        
        if @first_run
          @first_run = false
          
          register_signal_handlers unless ::Middleman::WINDOWS
          
          start_file_watcher unless options[:"disable-watcher"]
          
          @webrick.start
        end
      end

      # Detach the current Middleman::Application instance
      # @return [void]
      def stop
        puts "== The Middleman is shutting down"
        unmount_instance
      end
    
      # Simply stop, then start the server
      # @return [void]
      def reload
        stop
        start
      end

      # Stop the current instance, exit Webrick
      # @return [void]
      def shutdown
        stop
        @webrick.shutdown
      end
      
    private
      
      def start_file_watcher
        preview_server = self

        # Watcher Library
        require "listen"
    
        listener = Listen.to(Dir.pwd, :relative_paths => true)
      
        listener.change do |modified, added, removed|
          added_and_modified = (modified + added)

          if added_and_modified.length > 0
            # See if the changed file is config.rb or lib/*.rb
            return reload if needs_to_reload?(added_and_modified)

            # Otherwise forward to Middleman
            paths.each do |path|
              @app.files.did_change(path)
            end
          end
      
          if removed.length > 0
            # See if the changed file is config.rb or lib/*.rb
            return reload if needs_to_reload?(removed)

            # Otherwise forward to Middleman
            removed.each do |path|
              @app.files.did_delete(path)
            end
          end
        end
    
        # Don't block this thread
        listener.start(false)
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
        
        unless is_logging
          http_opts[:Logger] = ::WEBrick::Log::new(nil, 0)
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
  end
end