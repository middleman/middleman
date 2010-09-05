class Middleman::Features::Sprockets
  def initialize(app)
    require "middleman/features/sprockets/rack"
    app.use Middleman::Rack::Sprockets, 
      :root      => Middleman::Base.root, 
      :load_path => [ File.join("public", Middleman::Base.js_dir),
                      File.join("views",  Middleman::Base.js_dir) ]
  end
end

Middleman::Features.register :sprockets, Middleman::Features::Sprockets, { :auto_enable => true }

                                                
