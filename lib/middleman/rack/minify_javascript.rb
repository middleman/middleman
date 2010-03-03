begin
  require "yui/compressor"
rescue LoadError
  puts "YUI-Compressor not available. Install it with: gem install yui-compressor"
end
  
class Middleman::Rack::MinifyJavascript
  def initialize(app, options={})
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    
    if Middleman::Base.enabled?(:minify_javascript) && env["PATH_INFO"].match(/\.js$/) 
      compressor = ::YUI::JavaScriptCompressor.new(:munge => true)
      
      uncompressed_source = response.is_a?(::Rack::File) ? File.read(response.path) : response
      response = compressor.compress(uncompressed_source)
      headers["Content-Length"] = ::Rack::Utils.bytesize(response).to_s
    end
    
    [status, headers, response]
  end
end