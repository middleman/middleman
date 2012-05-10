# File changes are forwarded to the currently running app via HTTP
require "net/http"
require "fileutils"

module Middleman
  WINDOWS = !!(RUBY_PLATFORM =~ /(mingw|bccwin|wince|mswin32)/i) unless const_defined?(:WINDOWS)
end

module Middleman
  class Watcher
    class << self
      attr_accessor :singleton
      
      def start(options)
        self.singleton = new(options)
        self.singleton.watch! unless options[:"disable-watcher"]
        self.singleton.start
      end
      
      def ignore_list
        [
          /^\.sass-cache\//,
          /^\.git\//,
          /^\.gitignore$/,
          /^\.DS_Store$/,
          /^build\//,
          /^\.rbenv-.*$/,
          /^Gemfile$/,
          /^Gemfile\.lock$/,
          /~$/
        ]
      end
    end
    
    def initialize(options)
      @options = options
      register_signal_handlers unless ::Middleman::WINDOWS
    end
    
    def watch!
      local = self

      # Watcher Library
      require "listen"
      
      listener = Listen.to(Dir.pwd, :relative_paths => true)
      listener.change do |modified, added, removed|
        added_and_modified = modified + added

        if added_and_modified.length > 0
          local.run_on_change(added_and_modified)
        end
        
        if removed.length > 0
          local.run_on_deletion(removed)
        end
      end
      # Don't block this thread
      listener.start(false)
    end
    
    # Start an instance of Middleman::Application
    # @return [void]
    def start
      env = (@options[:environment] || "development").to_sym
      is_logging = @options.has_key?(:debug) && @options[:debug]
      
      app = ::Middleman.server.inst do
        set :environment, env
        set :logging, is_logging
      end
      
      app_rack = app.class.to_rack_app
      
      opts = @options.dup
      opts[:app] = app_rack
      opts[:logging] = is_logging
      puts "== The Middleman is standing watch on port #{opts[:port]||4567}"
      ::Middleman.start_server(opts)
    end
    
    # Stop the forked Middleman
    # @return [void]
    def stop
      puts "== The Middleman is shutting down"
      # TODO: Figure out some way to actually unload the whole thing
      #       or maybe just re-exec this same thing
    end
    
    # Simply stop, then start
    # @return [void]
    def reload
      stop
      start
    end
    
    # What to do on file change
    # @param [Array<String>] paths Array of paths that changed
    # @return [void]
    def run_on_change(paths)
      # See if the changed file is config.rb or lib/*.rb
      return reload if needs_to_reload?(paths)
      
      # Otherwise forward to Middleman
      paths.each do |path|
        tell_server(:change => path) unless self.class.ignore_list.any? { |r| path.match(r) }
      end
    end

    # What to do on file deletion
    # @param [Array<String>] paths Array of paths that were removed
    # @return [void]
    def run_on_deletion(paths)
      # See if the changed file is config.rb or lib/*.rb
      return reload if needs_to_reload?(paths)
      
      # Otherwise forward to Middleman
      paths.each do |path|
        tell_server(:delete => path) unless self.class.ignore_list.any? { |r| path.match(r) }
      end
    end
    
  private
    # Trap the interupt signal and shut down FSSM (and thus the server) smoothly
    def register_signal_handlers
      trap("INT")  { stop; exit(0) }
      trap("TERM") { stop }
      trap("QUIT") { stop; exit(0) }
    end

    # Whether the passed files are config.rb, lib/*.rb or helpers
    # @param [Array<String>] paths Array of paths to check
    # @return [Boolean] Whether the server needs to reload
    def needs_to_reload?(paths)
      return false # disable reloading for now
      paths.any? do |path|
        path.match(%{^config\.rb}) || path.match(%r{^lib/^[^\.](.*)\.rb$}) || path.match(%r{^helpers/^[^\.](.*)_helper\.rb$})
      end
    end
  
    # Send a message to the running server
    # @param [Hash] params Keys to be hashed and sent to server
    # @return [void]
    def tell_server(params={})
      uri = URI.parse("http://#{@options[:host]}:#{@options[:port]}/__middleman__")
      Net::HTTP.post_form(uri, {}.merge(params))
    end
  end
end
