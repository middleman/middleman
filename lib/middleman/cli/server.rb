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
    method_option "debug", 
      :type    => :boolean, 
      :default => false,
      :desc    => 'Print debug messages'
    def server
      params = {
        :port        => options["port"],
        :host        => options["host"],
        :environment => options["environment"],
        :debug       => options["debug"]
      }
      
      puts "== The Middleman is loading"
      Middleman::Guard.start(params)
    end
  end
  
  Base.map({ "s" => "server" })
end