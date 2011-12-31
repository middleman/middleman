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
          config.project_path    = root
          config.environment     = :development
          config.cache_path      = File.join(root, ".sass-cache")
          config.sass_dir        = File.join(source, css_dir)
          config.css_dir         = File.join(source, css_dir)
          config.javascripts_dir = File.join(source, js_dir)
          config.fonts_dir       = File.join(source, fonts_dir)
          config.images_dir      = File.join(source, images_dir)
          
          config.http_images_path = if respond_to? :http_images_path
            http_images_path
          else
            File.join(http_prefix, images_dir)
          end
          
          config.http_stylesheets_path = if respond_to? :http_css_path
            http_css_path
          else
            File.join(http_prefix, css_dir)
          end
          
          config.http_javascripts_path = if respond_to? :http_js_path
            http_js_path
          else
            File.join(http_prefix, js_dir)
          end

          config.http_fonts_path = if respond_to? :http_fonts_path
            http_fonts_path
          else
            File.join(http_prefix, fonts_dir)
          end
          
          config.asset_cache_buster :none
          config.output_style = :nested

          if respond_to?(:asset_host) && asset_host.is_a?(Proc)
            config.asset_host(&asset_host)
          end
        end
        
        # Change paths when in build mode. Required for relative paths
        configure :build do
          ::Compass.configuration do |config|
            config.environment = :production
            config.css_dir    = File.join(build_dir, css_dir)
            config.images_dir = File.join(build_dir, images_dir)
            config.fonts_dir  = File.join(build_dir, fonts_dir)
          end
        end
        
        run_hook :compass_config, ::Compass.configuration
        run_hook :after_compass_config
      end
    end
    alias :included :registered
  end
end