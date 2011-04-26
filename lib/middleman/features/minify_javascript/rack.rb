begin
  require "yui/compressor"
rescue LoadError
  puts "YUI-Compressor not available. Install it with: gem install yui-compressor"
end
  
module Middleman
  module Rack
  
    class MinifyJavascript
      def initialize(app, options={})
        @app = app
      end

      def call(env)
        status, headers, response = @app.call(env)
    
        if env["PATH_INFO"].match(/\.js$/)
          compressor = ::YUI::JavaScriptCompressor.new(:munge => true)
      
          if response.is_a?(::Rack::File) or response.is_a?(Sinatra::Helpers::StaticFile)
            uncompressed_source = File.read(response.path)
          else
            uncompressed_source = response.join
          end
          minified = compressor.compress(uncompressed_source)
          headers["Content-Length"] = ::Rack::Utils.bytesize(minified).to_s
          response = [minified]
        end
    
        [status, headers, response]
      end
    end
    
  end
end
