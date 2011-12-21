module Middleman::CLI
  class Server < Thor::Group
    check_unknown_options!
  
    desc "server [options]"
    class_option "environment", 
      :aliases => "-e", 
      :default => ENV['MM_ENV'] || ENV['RACK_ENV'] || 'development', 
      :desc    => "The environment Middleman will run under"
    class_option :host,
      :type => :string,
      :aliases => "-h",
      # :required => true,
      :default => "0.0.0.0", 
      :desc => "Bind to HOST address"
    class_option "port",
      :aliases => "-p", 
      :default => "4567", 
      :desc    => "The port Middleman will listen on"
    class_option "debug", 
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
  
  Base.register(Server, :server, "server [options]", "Start the preview server")
  Base.map({ "s" => "server" })
  Base.default_task :server
end