require "guard"
require "guard/guard"
require "rbconfig"

if Config::CONFIG['host_os'].downcase =~ %r{mingw}
  require "win32/process"
end

# Quiet down Guard
ENV['GUARD_ENV'] = 'test'

module Middleman
  module Guard
    def self.add_guard(&block)
      # Deprecation Warning
      $stderr.puts "== Middleman::Guard.add_guard has been removed. Update your extensions to versions which support this change."
      exit
    end
  
    def self.start(options={})
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

module Guard
  class Middleman < Guard
    def initialize(watchers = [], options = {})
      super
      @options = options
    end
    
    def start
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
        server_restart
      elsif !@app.nil?
        paths.each do |path|
          @app.file_did_change(path)
        end
      end
    end

    def run_on_deletion(paths)
      if !@app.nil?
        paths.each do |path|
          @app.file_did_delete(path)
        end
      end
    end
    
  private
    def server_restart
      server_stop
      server_start
    end
    
    def server_start
      app = ::Middleman.server
      app.set :environment, @options[:environment].to_sym

      puts "== The Middleman is standing watch on port #{@options[:Port]||4567}"
      @app = app.new!
      app_rack = app.build_new(@app)

      @server_job = fork do
        opts = @options.dup
        opts[:app] = app_rack
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