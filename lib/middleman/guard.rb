require "guard"
require "guard/guard"
require "rbconfig"
require "net/http"
require "thin"

if RbConfig::CONFIG['host_os'].downcase =~ %r{mingw}
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

        ::Guard.start({ 
          :guardfile_contents      => guardfile_contents,
          :watch_all_modifications => true
        })
      end
    end
  end
end

# Shut up Guard
module Guard::UI
  class << self
    def info(message, options = { }); end
  end
end

# @private
module Guard
  class Middleman < Guard
    def initialize(watchers = [], options = {})
      super
      @options = options
    end
    
    def start
      @server_job = fork do
        env = (@options[:environment] || "development").to_sym
        is_logging = @options.has_key?(:debug) && (@options[:debug] == "true")
        app = ::Middleman.server.inst do
          set :environment, env
          set :logging, is_logging
        end
        
        ::Thin::Logging.silent = !is_logging
        
        app_rack = app.class.to_rack_app
        
        opts = @options.dup
        opts[:app] = app_rack
        puts "== The Middleman is standing watch on port #{opts[:port]||4567}"
        ::Middleman.start_server(opts)
      end
    end
    
    def stop
      puts "== The Middleman is shutting down"
      Process.kill("KILL", @server_job)
      Process.wait @server_job
      @server_job = nil
    end
    
    def reload
      stop
      start
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
      else
        paths.each do |path|
          file_did_change(path)
        end
      end
    end

    def run_on_deletion(paths)
      paths.each do |path|
        file_did_delete(path)
      end
    end
    
  private
    def talk_to_server(params={})
      uri = URI.parse("http://#{@options[:host]}:#{@options[:port]}/__middleman__")
      Net::HTTP.post_form(uri, {}.merge(params))
    end
    
    def file_did_change(path)
      talk_to_server :change => path
    end
    
    def file_did_delete(path)
      talk_to_server :delete => path
    end
  end
end

trap(:INT) do 
  ::Guard.stop
  exit
end