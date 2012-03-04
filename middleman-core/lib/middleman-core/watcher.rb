# File changes are forwarded to the currently running app via HTTP
require "net/http"

require "win32/process" if ::Middleman::WINDOWS

require "fileutils"

module Middleman
  class Watcher
    class << self
      attr_accessor :singleton
      
      def start(options)
        self.singleton = new(options)
        self.singleton.watch! unless options[:"disable-watcher"]
      end
      
      def ignore_list
        [
          /\.sass-cache/,
          /\.git/,
          /\.DS_Store/,
          /build/,
          /\.rbenv-version/,
          /Gemfile/,
          /\.mm-pid/
        ]
      end
    end
    
    def initialize(options)
      @options = options
      
      register_signal_handlers
      start
    end
    
    # What command is sent to kill instances
    # @return [Symbol, Fixnum]
    def kill_command
      ::Middleman::WINDOWS ? 1 : "TERM"
    end
    
    def watch!
      local = self

      # Watcher Library
      require "listen"
      
      Listen.to(Dir.pwd) do |modified, added, removed|
        local.run_on_change(modified)  if modified.length > 0
        local.run_on_change(added)     if added.length > 0
        local.run_on_deletion(removed) if removed.length > 0
      end
    end
    
    def pid_name
      ".mm-pid-#{@options[:port]||4567}"
    end
    
    def kill_pid!
      if File.exists?(pid_name)
        current_pid = File.open(pid_name, 'rb') { |f| f.read }
        begin
          Process.kill(kill_command, current_pid.to_i)
        rescue
        ensure
          FileUtils.rm(pid_name) if File.exists?(pid_name)
        end
      end
    end
    
    # Start Middleman in a fork
    # @return [void]
    def start
      if @options[:"disable-watcher"]
        bootup
      else
        kill_pid!
        
        @server_job = fork {
          # trap("INT")  { exit(0) }
          # trap("TERM") { exit(0) }
          # trap("QUIT") { exit(0) }
          bootup
        }
        
        File.open(pid_name, "w+") { |f| f.write(@server_job) }
      end
    end
    
    # Start an instance of Middleman::Base
    # @return [void]
    def bootup
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
      if !@options[:"disable-watcher"]
        kill_pid!
        # Process.kill(::Middleman::WINDOWS ? :KILL : :TERM, @server_job)
        # Process.wait @server_job
        # @server_job = nil
      end
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
      #return reload if needs_to_reload?(paths)
      
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
      #return reload if needs_to_reload?(paths)
      
      # Otherwise forward to Middleman
      paths.each do |path|
        tell_server(:delete => path) unless self.class.ignore_list.any? { |r| path.match(r) }
      end
    end
    
  private
    # Trap the interupt signal and shut down FSSM (and thus the server) smoothly
    def register_signal_handlers
      # trap("INT")  { stop; exit(0) }
      trap("TERM") { stop }
      # trap("QUIT") { stop; exit(0) }
    end
  
    # Whether the passed files are config.rb, lib/*.rb or helpers
    # @param [Array<String>] paths Array of paths to check
    # @return [Boolean] Whether the server needs to reload
    def needs_to_reload?(paths)
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