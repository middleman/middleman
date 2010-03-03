begin
  require "yui/compressor"
rescue LoadError
  puts "YUI-Compressor not available. Install it with: gem install yui-compressor"
end

class Middleman::Rack::MinifyCSS
  def initialize(app, options={})
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
  
    if Middleman::Base.enabled?(:minify_css) && env["PATH_INFO"].match(/\.css$/)
      compressor = ::YUI::CssCompressor.new
      
      uncompressed_source = response.is_a?(::Rack::File) ? File.read(response.path) : response
      response = compressor.compress(uncompressed_source)
      headers["Content-Length"] = ::Rack::Utils.bytesize(response).to_s
    end

    [status, headers, response]
  end
end