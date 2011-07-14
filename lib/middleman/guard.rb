require "guard"
require "guard/guard"

module Middleman::Guard
  def self.start(options={})
    options_hash = ""
    options.each do |k,v|
      options_hash << ", :#{k} => '#{v}'"
    end
    
    ::Guard.start({
      :guardfile_contents => %Q{
        guard 'MiddlemanServer'#{options_hash} do 
          watch("config.rb")
        end
      }
    })
  end
end

module Guard
  class MiddlemanServer < Guard
    def initialize(watchers = [], options = {})
      super
      @options = {
        :port => '4567'
      }.update(options)
    end
    
    def start
      server_start
    end
  
    def run_on_change(paths)
      server_stop
      server_start
    end

  private
    def server_start
      puts "== The Middleman is standing watch on port #{@options[:port]}"
      @server_options = { :Port => @options[:port], :AccessLog => [] }
      @server_job = fork do
        @server_options[:app] = Middleman.server.new
        ::Rack::Server.new(@server_options).start
      end
    end
  
    def server_stop
      puts "== The Middleman is shutting down"
      Process.kill("KILL", @server_job)
      Process.wait @server_job
      @server_job = nil
      @server_options[:app] = nil
    end
  end
end