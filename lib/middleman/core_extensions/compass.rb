module Middleman::CoreExtensions::Compass
  class << self
    def registered(app)
      # Where to look for fonts
      app.set :fonts_dir, "fonts"
      app.define_hook :after_compass_config
    
      app.extend ClassMethods
        
      require "compass"
      
      # Susy grids
      begin
        require "susy"
      rescue LoadError
      end

      app.after_configuration do
        # Support a stand-alone compass config file
        # Many options are overwritten by Middleman, but the config is a good
        # place to add:
        # * output_style
        # * disable_warnings
        # * sass_options
        # * line_comments
        # * sprite_engine
        # * chunky_png_options
        compass_config_file = File.join(app.root, "compass.config")
        if File.exists?(compass_config_file)
          ::Compass.add_project_configuration(compass_config_file)
        end
        
        ::Compass.configuration do |config|
          config.project_path          = app.root
          config.environment           = :development
          config.cache_path            = File.join(app.root, ".sass-cache")
          
          views_root = File.basename(app.views)
          config.sass_dir              = File.join(views_root, app.css_dir)
          config.css_dir               = File.join(views_root, app.css_dir)
          config.javascripts_dir       = File.join(views_root, app.js_dir)
          config.fonts_dir             = File.join(views_root, app.fonts_dir)
          config.images_dir            = File.join(views_root, app.images_dir)
          
          config.http_images_path = if app.respond_to? :http_images_path
            app.http_images_path
          else
            File.join(app.http_prefix || "/", app.images_dir)
          end
          
          config.http_stylesheets_path = if app.respond_to? :http_css_path
            app.http_css_path
          else
            File.join(app.http_prefix || "/", app.css_dir)
          end
          
          config.http_javascripts_path = if app.respond_to? :http_js_path
            app.http_js_path
          else
            File.join(app.http_prefix || "/", app.js_dir)
          end

          config.http_fonts_path = if app.respond_to? :http_fonts_path
            app.http_fonts_path
          else
            File.join(app.http_prefix || "/", app.fonts_dir)
          end
          
          config.asset_cache_buster :none
          config.output_style = :nested

          # config.add_import_path(config.sass_dir)
        end
        
        # Required for relative paths
        configure :build do
          ::Compass.configuration do |config|
            config.environment = :production
             
            build_root = File.basename(self.build_dir)
            config.css_dir     = File.join(build_root, self.css_dir)
            config.images_dir  = File.join(build_root, self.images_dir)
            config.fonts_dir   = File.join(build_root, self.fonts_dir)
          end
        end
        
        run_hook :after_compass_config, ::Compass.configuration
      end
    end
    alias :included :registered
  end
  
  module ClassMethods
    # Add a block/proc to be run after features have been setup
    def compass_config(&block)
      after_compass_config(&block)
    end
    
    def after_compass_config(&block)
      after_compass_config(&block)
    end
  end
end