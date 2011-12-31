# Guard watches the filesystem for changes
require "guard"
require "guard/guard"

# File changes are forwarded to the currently running app via HTTP
require "net/http"

# Support forking on Windows
require "win32/process" if Middleman::WINDOWS

# The Guard namespace
module Middleman::Guard
  
  # Start guard
  # @param [Hash] options
  # @return [void]
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
      :watch_all_modifications => true,
      :no_interactions => true
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
      
      # Save options
      @options = options
    end
    
    # Start Middleman in a fork
    # @return [void]
    def start
      @server_job = fork {
        Signal.trap(::Middleman::WINDOWS ? :KILL : :TERM) { exit! }
        bootup
      }
    end
    
    # Start an instance of Middleman::Base
    # @return [void]
    def bootup
      env = (@options[:environment] || "development").to_sym
      is_logging = @options.has_key?(:debug) && (@options[:debug] == "true")
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
      Process.kill(::Middleman::WINDOWS ? :KILL : :TERM, @server_job)
      Process.wait @server_job
      @server_job = nil
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
      paths.each { |path| tell_server(:change => path) }
    end

    # What to do on file deletion
    # @param [Array<String>] paths Array of paths that were removed
    # @return [void]
    def run_on_deletion(paths)
      # See if the changed file is config.rb or lib/*.rb
      return reload if needs_to_reload?(paths)
      
      # Otherwise forward to Middleman
      paths.each { |path| tell_server(:delete => path) }
    end
    
    # What command is sent to kill instances
    # @return [Symbol, Fixnum]
    def self.kill_command
      ::Middleman::WINDOWS ? 1 : :INT
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
    # @return [void]
    def tell_server(params={})
      uri = URI.parse("http://#{@options[:host]}:#{@options[:port]}/__middleman__")
      Net::HTTP.post_form(uri, {}.merge(params))
    end
  end
end

# Trap the interupt signal and shut down Guard (and thus the server) smoothly
trap(::Guard::Middleman.kill_command) do
  ::Guard.stop
  exit!(0)
end