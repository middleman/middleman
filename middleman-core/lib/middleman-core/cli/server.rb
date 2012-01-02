# CLI Module
module Middleman::Cli
  
  # Server thor task
  class Server < Thor
    check_unknown_options!
    
    namespace :server
    
    desc "server [options]", "Start the preview server"
    method_option "environment", 
      :aliases => "-e", 
      :default => ENV['MM_ENV'] || ENV['RACK_ENV'] || 'development', 
      :desc    => "The environment Middleman will run under"
    method_option :host,
      :type => :string,
      :aliases => "-h",
      :default => "0.0.0.0", 
      :desc => "Bind to HOST address"
    method_option "port",
      :aliases => "-p", 
      :default => "4567", 
      :desc    => "The port Middleman will listen on"
    method_option "verbose", 
      :type    => :boolean, 
      :default => false,
      :desc    => 'Print debug messages'
    
    # Start the server
    def server
      if !ENV["MM_ROOT"]
        puts "== Warning: Could not find a Middleman project config.rb"
        puts "== Treating directory as a static site to be served"
        ENV["MM_ROOT"] = Dir.pwd
        ENV["MM_SOURCE"] = ""
      end

      params = {
        :port        => options["port"],
        :host        => options["host"],
        :environment => options["environment"],
        :debug       => options["verbose"]
      }
      
      puts "== The Middleman is loading"
      Middleman::Watcher.start(params)
    end
  end
  
  # Map "s" to "server"
  Base.map({ "s" => "server" })
end