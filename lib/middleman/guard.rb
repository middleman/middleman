# Guard watches the filesystem for changes
require "guard"
require "guard/guard"

# File changes are forwarded to the currently running app via HTTP
require "net/http"

# Support forking on Windows
require "rbconfig"
require "win32/process" if RbConfig::CONFIG['host_os'].downcase =~ %r{mingw}

module Middleman::Guard
  def self.start(options={})
    # Forward CLI options to Guard
    options_hash = options.map { |k,v| ", :#{k} => '#{v}'" }.join
  
    # Watch all files in project, even hidden ones.
    ::Guard.start({
      :guardfile_contents      => %Q{
        guard 'middleman'#{options_hash} do 
          watch(%r{(.*)})
        end
      },
      :watch_all_modifications => true
    })
  end
end

# @private
module Guard
  # Monkeypatch Guard into being quiet
  module UI
    class << self
      def info(message, options = { }); end
    end
  end
  
  # Guards must be in the Guard module to be picked up
  class Middleman < Guard
    # Save the options for later
    def initialize(watchers = [], options = {})
      super
      @options = options
    end
    
    # Start Middleman in a fork
    def start
      @server_job = fork do
        env = (@options[:environment] || "development").to_sym
        is_logging = @options.has_key?(:debug) && (@options[:debug] == "true")
        app = ::Middleman.server.inst do
          set :environment, env
          set :logging, is_logging
        end
        
        require "thin"
        ::Thin::Logging.silent = !is_logging
        
        app_rack = app.class.to_rack_app
        
        opts = @options.dup
        opts[:app] = app_rack
        puts "== The Middleman is standing watch on port #{opts[:port]||4567}"
        ::Middleman.start_server(opts)
      end
    end
    
    # Stop the forked Middleman
    def stop
      puts "== The Middleman is shutting down"
      Process.kill("KILL", @server_job)
      Process.wait @server_job
      @server_job = nil
    end
    
    # Simply stop, then start
    def reload
      stop
      start
    end
  
    # What to do on file change
    # @param [Array<String>] paths Array of paths that changed
    def run_on_change(paths)
      # See if the changed file is config.rb or lib/*.rb
      return reload if needs_to_reload?(paths)
      
      # Otherwise forward to Middleman
      paths.each { |path| tell_server(:change => path) }
    end

    # What to do on file deletion
    # @param [Array<String>] paths Array of paths that were removed
    def run_on_deletion(paths)
      # See if the changed file is config.rb or lib/*.rb
      return reload if needs_to_reload?(paths)
      
      # Otherwise forward to Middleman
      paths.each { |path| tell_server(:delete => path) }
    end
    
  private
    # Whether the passed files are config.rb or lib/*.rb
    # @param [Array<String>] paths Array of paths to check
    # @return [Boolean] Whether the server needs to reload
    def needs_to_reload?(paths)
      paths.any? do |path|
        path.match(%{^config\.rb}) || path.match(%r{^lib/^[^\.](.*)\.rb$})
      end
    end
  
    # Send a message to the running server
    # @param [Hash] params Keys to be hashed and sent to server
    def tell_server(params={})
      uri = URI.parse("http://#{@options[:host]}:#{@options[:port]}/__middleman__")
      Net::HTTP.post_form(uri, {}.merge(params))
    end
  end
end

# Trap the interupt signal and shut down Guard (and thus the server) smoothly
trap(:INT) do 
  ::Guard.stop
  exit
end