module Middleman
  module CoreExtensions
    
    # Forward the settings on config.rb and the result of registered 
    # extensions to Compass
    module Compass
  
      # Extension registered
      class << self
    
        # Once registered
        def registered(app)
          # Require the library
          require "compass"
      
          # Where to look for fonts
          app.set :fonts_dir, "fonts"
      
          # Hooks to manually update the compass config after we're 
          # done with it
          app.define_hook :compass_config

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

              # Disable this initially, the cache_buster extension will
              # re-enable it if requested.
              config.asset_cache_buster :none
              
              # Disable this initially, the relative_assets extension will
              # re-enable it if requested.
              config.relative_assets = false
              
              # Default output style
              config.output_style = :nested

              if respond_to?(:asset_host) && asset_host.is_a?(Proc)
                config.asset_host(&asset_host)
              end
            end
              
            # Call hook
            run_hook :compass_config, ::Compass.configuration
            
            # Tell Tilt to use it as well (for inline sass blocks)
            ::Tilt.register 'sass', CompassSassTemplate
            ::Tilt.prefer(CompassSassTemplate)

            # Tell Tilt to use it as well (for inline scss blocks)
            ::Tilt.register 'scss', CompassScssTemplate
            ::Tilt.prefer(CompassScssTemplate)
          end
        end
        alias :included :registered
      end

    end
    
    # A Compass template for Tilt
    class CompassSassTemplate < ::Middleman::Renderers::Sass::SassPlusCSSFilenameTemplate
    private
      def sass_options
        super.merge(::Compass.configuration.to_sass_engine_options)
      end
    end
    
    class CompassScssTemplate <  ::Middleman::Renderers::Sass::ScssPlusCSSFilenameTemplate
    private
      def sass_options
        super.merge(::Compass.configuration.to_sass_engine_options)
      end
    end
      
  end
end