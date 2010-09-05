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
      
          uncompressed_source = response.is_a?(::Rack::File) ? File.read(response.path) : response
          response = compressor.compress(uncompressed_source)
          headers["Content-Length"] = ::Rack::Utils.bytesize(response).to_s
        end
    
        [status, headers, response]
      end
    end
    
  end
end