require "guard"
require "guard/guard"
require "rbconfig"

if Config::CONFIG['host_os'].downcase =~ %r{mingw}
  require "win32/process"
end

module Middleman
  module Guard
    class << self
      def add_guard(&block)
        # Deprecation Warning
        puts "== Middleman::Guard.add_guard has been removed. Update your extensions to versions which support this change."
      end
  
      def start(options={})
        options_hash = ""
        options.each do |k,v|
          options_hash << ", :#{k} => '#{v}'"
        end
      
        guardfile_contents = %Q{
          guard 'middleman'#{options_hash} do 
            watch(%r{(.*)})
          end
        }

        ::Guard.start({ :guardfile_contents => guardfile_contents })
      end
    end
  end
end

module Guard
  class Middleman < Guard
    def initialize(watchers = [], options = {})
      super
      @options = options
    end
    
    def start
      server_start
    end
    
    def reload
      server_stop
      server_start
    end
  
    def run_on_change(paths)
      needs_to_restart = false
      
      paths.each do |path|
        if path.match(%{^config\.rb}) || path.match(%r{^lib/^[^\.](.*)\.rb$})
          needs_to_restart = true
          break
        end
      end
      
      if needs_to_restart
        reload
      elsif !@app.nil?
        paths.each do |path|
          @app.logger.debug :file_change, Time.now, path if @app.settings.logging?
          @app.file_did_change(path)
        end
      end
    end

    def run_on_deletion(paths)
      if !@app.nil?
        paths.each do |path|
          @app.logger.debug :file_remove, Time.now, path if @app.settings.logging?
          @app.file_did_delete(path)
        end
      end
    end
    
  private
    def server_start
      # Quiet down Guard
      # ENV['GUARD_ENV'] = 'test' if @options[:debug] == "true"
      
      env = (@options[:environment] || "development").to_sym
      is_logging = @options.has_key?(:debug) && (@options[:debug] == "true")
      @app = ::Middleman.server.inst do
        set :environment, env
        set :logging, is_logging
      end
      
      app_rack = @app.class.to_rack_app

      @server_job = fork do
        opts = @options.dup
        opts[:app] = app_rack
        puts "== The Middleman is standing watch on port #{opts[:port]||4567}"
        ::Middleman.start_server(opts)
      end
    end
  
    def server_stop
      puts "== The Middleman is shutting down"
      Process.kill("KILL", @server_job)
      Process.wait @server_job
      @server_job = nil
      @app = nil
    end
  end
end