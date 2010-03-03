begin
  require 'sprockets'
  require 'middleman/rack/sprockets+ruby19' # Sprockets ruby 1.9 duckpunch
rescue LoadError
  puts "Sprockets not available. Install it with: gem install sprockets"
end
  
class Middleman::Rack::Sprockets
  def initialize(app, options={})
    @app = app
    @options = options
  end

  def call(env)
    if env["PATH_INFO"].match(/\.js$/)
      public_file_path = File.join(Middleman::Base.public, env["PATH_INFO"])
      view_file_path   = File.join(Middleman::Base.views,  env["PATH_INFO"])
      
      source_file = Rack::File.new(Middleman::Base.public) if File.exists?(public_file_path) 
      source_file = Rack::File.new(Middleman::Base.views)  if File.exists?(view_file_path)
      
      if source_file
        status, headers, response = source_file.call(env)
        secretary = ::Sprockets::Secretary.new(@options.merge( :source_files => [ response.path ] ))
        response = secretary.concatenation.to_s
        headers["Content-Length"] = ::Rack::Utils.bytesize(response).to_s
        return [status, headers, response]
      end
    end
    
    @app.call(env)
  end
end

Middleman::Base.supported_formats << "js"