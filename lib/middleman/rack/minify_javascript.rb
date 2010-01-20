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
    if Middleman::Base.enabled?(:minify_javascript) &&
       env["DOWNSTREAM"] && env["PATH_INFO"].match(/\.js$/) 
      
      compressor = ::YUI::JavaScriptCompressor.new(:munge => true)
      
      source = env["DOWNSTREAM"][2].is_a?(::Rack::File) ?
                 File.read(env["DOWNSTREAM"][2].path) :
                 env["DOWNSTREAM"][2]

      env["DOWNSTREAM"][2] = compressor.compress(source)
      env["DOWNSTREAM"][1]["Content-Length"] = ::Rack::Utils.bytesize(env["DOWNSTREAM"][2]).to_s
    end
    
    @app.call(env)
  end
end