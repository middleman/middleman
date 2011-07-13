module Middleman::CoreExtensions::Compass
  class << self
    def registered(app)
      app.extend ClassMethods
        
      require "compass"
      
      # Susy grids
      begin
        require "susy"
      rescue LoadError
      end

      app.after_feature_init do
        views_root = File.basename(app.views)
        ::Compass.configuration do |config|
          # config.cache            = false # For sassc files
          config.cache_path            = File.join(app.root, ".sass-cache")
          config.project_path          = app.root
          config.sass_dir              = File.join(views_root, app.css_dir)
          config.output_style          = :nested
          config.fonts_dir             = File.join(views_root, app.fonts_dir)
          config.css_dir               = File.join(views_root, app.css_dir)
          config.images_dir            = File.join(views_root, app.images_dir)      
          config.http_images_path      = app.http_images_path rescue File.join(app.http_prefix || "/", app.images_dir)
          config.http_stylesheets_path = app.http_css_path rescue File.join(app.http_prefix || "/", app.css_dir)
          config.asset_cache_buster :none

          config.add_import_path(config.sass_dir)
        end
        
        # Required for relative paths
        configure :build do
           build_root = File.basename(self.build_dir)
           ::Compass.configuration do |config|
             config.css_dir    = File.join(build_root, self.css_dir)
             config.images_dir = File.join(build_root, self.images_dir)
           end
         end
        
        app.execute_after_compass_init!
        
        app.set :sass, ::Compass.configuration.to_sass_engine_options
      end
    end
    alias :included :registered
  end
  
  module ClassMethods
    # Add a block/proc to be run after features have been setup
    def after_compass_init(&block)
      @run_after_compass ||= []
      @run_after_compass << block
    end
    
    def execute_after_compass_init!
      @run_after_compass ||= []
      @run_after_compass.each { |block| class_eval(&block) }
    end
  end
end