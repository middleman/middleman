module Middleman
  class CompassExtension < Extension
    def initialize(app, options_hash={}, &block)
      require 'middleman-core/renderers/sass'
      require 'compass'

      super

      # Hooks to manually update the compass config after we're
      # done with it
      app.define_hook :compass_config
    end

    def after_configuration
      ::Compass.configuration do |compass|
        compass.project_path    = app.source_dir
        compass.environment     = :development
        compass.cache           = false
        compass.sass_dir        = app.config[:css_dir]
        compass.css_dir         = app.config[:css_dir]
        compass.javascripts_dir = app.config[:js_dir]
        compass.fonts_dir       = app.config[:fonts_dir]
        compass.images_dir      = app.config[:images_dir]
        compass.http_path       = app.config[:http_prefix]

        # Disable this initially, the cache_buster extension will
        # re-enable it if requested.
        compass.asset_cache_buster { |_| nil }

        # Disable this initially, the relative_assets extension will

        compass.relative_assets = false

        # Default output style
        compass.output_style = :nested
      end

      # Call hook
      app.run_hook_for :compass_config, app, ::Compass.configuration

      # Tell Tilt to use it as well (for inline sass blocks)
      ::Tilt.register 'sass', CompassSassTemplate
      ::Tilt.prefer(CompassSassTemplate)

      # Tell Tilt to use it as well (for inline scss blocks)
      ::Tilt.register 'scss', CompassScssTemplate
      ::Tilt.prefer(CompassScssTemplate)
    end

    # A Compass Sass template for Tilt, adding our options in
    class CompassSassTemplate < ::Middleman::Renderers::Sass::SassPlusCSSFilenameTemplate
      def sass_options
        super.merge(::Compass.configuration.to_sass_engine_options)
      end
    end

    # A Compass Scss template for Tilt, adding our options in
    class CompassScssTemplate < ::Middleman::Renderers::Sass::ScssPlusCSSFilenameTemplate
      def sass_options
        super.merge(::Compass.configuration.to_sass_engine_options)
      end
    end
  end
end