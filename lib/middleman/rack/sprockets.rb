begin
  require 'sprockets'
  require 'middleman/rack/sprockets+ruby19' # Sprockets ruby 1.9 duckpunch
rescue LoadError
  puts "Sprockets not available. Install it with: gem install sprockets"
end
  
class Middleman::Rack::Sprockets
  def initialize(app, options={})
    @app = app
  end

  def call(env)
    path = env["PATH_INFO"]
    
    if env["DOWNSTREAM"] && path.match(/\.js$/)
      source = "public" if File.exists?(File.join(Middleman::Base.views, path)) 
      source = "views" if File.exists?(File.join(Middleman::Base.views, path))
      
      if source
        source_file = env["DOWNSTREAM"][2].is_a?(::Rack::File) ? 
                        env["DOWNSTREAM"][2].path : 
                        env["DOWNSTREAM"][2]
      
        secretary = ::Sprockets::Secretary.new( :root         => Middleman::Base.root,
                                                :source_files => [ source_file ],
                                                :load_path    => [ File.join("public", Middleman::Base.js_dir),
                                                                   File.join("views", Middleman::Base.js_dir) ])
    
        env["DOWNSTREAM"][2] = secretary.concatenation.to_s
        env["DOWNSTREAM"][1]["Content-Length"] = ::Rack::Utils.bytesize(env["DOWNSTREAM"][2]).to_s
      end
    end
    
    @app.call(env)
  end
end

Middleman::Base.supported_formats << "js"