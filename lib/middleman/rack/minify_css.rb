begin
  require "yui/compressor"
rescue LoadError
  puts "YUI-Compressor not available. Install it with: gem install yui-compressor"
end
  
module Middleman
  module Rack
    class MinifyCSS
      def initialize(app, options={})
        @app = app
      end

      def call(env)
        if env["DOWNSTREAM"] && env["PATH_INFO"].match(/\.css$/) && Middleman::Base.enabled?(:minify_css)
          compressor = ::YUI::CssCompressor.new
          
          source = env["DOWNSTREAM"][2].is_a?(::Rack::File) ? File.read(env["DOWNSTREAM"][2].path) : env["DOWNSTREAM"][2]
          env["DOWNSTREAM"][2] = compressor.compress(source)
          env["DOWNSTREAM"][1]["Content-Length"] = ::Rack::Utils.bytesize(env["DOWNSTREAM"][2]).to_s
        end
        
        @app.call(env)
      end
    end
  end
end