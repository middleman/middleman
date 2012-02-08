# Forward the settings on config.rb and the result of registered extensions
# to Compass
module Middleman::CoreExtensions::Compass
  
  # Extension registered
  class << self
    
    # Once registered
    def registered(app)
      require "compass"
      
      # Where to look for fonts
      app.set :fonts_dir, "fonts"
      app.define_hook :compass_config
      app.define_hook :after_compass_config

      app.after_configuration do
        ::Compass.configuration do |config|
          config.project_path    = source_dir
          config.environment     = :development
          config.cache_path      = File.join(root, ".sass-cache")
          config.sass_dir        = css_dir
          config.css_dir         = css_dir
          config.javascripts_dir = js_dir
          config.fonts_dir       = fonts_dir
          config.images_dir      = images_dir
          config.http_path       = http_prefix

          config.asset_cache_buster :none
          config.output_style = :nested

          if respond_to?(:asset_host) && asset_host.is_a?(Proc)
            config.asset_host(&asset_host)
          end
        end
        
        if build?
          ::Compass.configuration do |config|
            config.environment  = :production
            config.project_path = File.join(root, build_dir)
          end
        end
        
        run_hook :compass_config, ::Compass.configuration
        run_hook :after_compass_config
      end
    end
    alias :included :registered
  end
end