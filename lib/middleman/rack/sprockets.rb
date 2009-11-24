begin
  require 'sprockets'
  require 'middleman/rack/sprockets+ruby19' # Sprockets ruby 1.9 duckpunch
  
rescue LoadError
  puts "Sprockets not available. Install it with: gem install sprockets"
end

begin
  require "yui/compressor"
rescue LoadError
  puts "YUI-Compressor not available. Install it with: gem install yui-compressor"
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
            
        if path.match(/\.js$/)
          if File.exists?(source)
            secretary = ::Sprockets::Secretary.new( :root   => Middleman::Base.root,
                                                    :source_files => [ File.join("views", path) ],
                                                    :load_path    => [ File.join("public", Middleman::Base.js_dir),
                                                                       File.join("views", Middleman::Base.js_dir) ])
          
            result = secretary.concatenation.to_s
          else
            result = File.read(File.join(Middleman::Base.public, path))
          end
          
          
          if Middleman::Base.respond_to?(:minify_javascript?) && Middleman::Base.minify_javascript?
            compressor = ::YUI::JavaScriptCompressor.new(:munge => true)
            result = compressor.compress(result)
          end

          [200, { "Content-Type" => "text/javascript" }, [result]]
        else
          @app.call(env)
        end
      end
    end
  end
end

Middleman::Base.supported_formats << "js"