begin
  require 'sprockets'
  require 'middleman/rack/sprockets+ruby19' # Sprockets ruby 1.9 duckpunch
rescue LoadError
  puts "Sprockets not available. Install it with: gem install sprockets"
end
  
module Middleman
  module Rack
    class Sprockets
      def initialize(app, options={})
        @app = app
      end

      def call(env)
        path   = env["PATH_INFO"]
        source = File.join(Middleman::Base.views, path)
            
        if path.match(/\.js$/) && File.exists?(source)
          secretary = ::Sprockets::Secretary.new( :root   => Middleman::Base.root,
                                                  :source_files => [ File.join("views", path) ],
                                                  :load_path    => [ File.join("public", Middleman::Base.js_dir),
                                                                     File.join("views", Middleman::Base.js_dir) ])

          [200, { "Content-Type" => "text/javascript" }, [secretary.concatenation.to_s]]
        else
          @app.call(env)
        end
      end
    end
  end
end

Middleman::Base.supported_formats << "js"