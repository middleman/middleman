module Middleman::Cli
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
      # :required => true,
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
    def server
      if !ENV["MM_ROOT"]
        $stderr.puts "== Error: Could not find a Middleman project config, perhaps you are in the wrong folder?"
        exit(1)
      end

      params = {
        :port        => options["port"],
        :host        => options["host"],
        :environment => options["environment"],
        :debug       => options["verbose"]
      }
      
      puts "== The Middleman is loading"
      Middleman::Guard.start(params)
    end
  end
  
  Base.map({ "s" => "server" })
end