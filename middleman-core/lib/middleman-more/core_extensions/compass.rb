require 'middleman-core/renderers/sass'
require 'compass'

class Middleman::CoreExtensions::Compass < ::Middleman::Extension
  def initialize(app, options_hash={}, &block)
    super

    # Hooks to manually update the compass config after we're
    # done with it
    app.define_hook :compass_config

    # Location of SASS/SCSS files external to source directory.
    # @return [Array]
    #   config[:sass_assets_paths] = ["#{root}/assets/sass/", "/path/2/external/sass/repository/"]
    app.config.define_setting :sass_assets_paths, [], 'Paths to extra SASS/SCSS files'
  end

  def after_configuration
    ::Compass.configuration do |compass_config|
      compass_config.project_path    = app.source_dir
      compass_config.environment     = :development
      compass_config.cache           = false
      compass_config.sass_dir        = app.config[:css_dir]
      compass_config.css_dir         = app.config[:css_dir]
      compass_config.javascripts_dir = app.config[:js_dir]
      compass_config.fonts_dir       = app.config[:fonts_dir]
      compass_config.images_dir      = app.config[:images_dir]
      compass_config.http_path       = app.config[:http_prefix]

      compass_config.additional_import_paths = []
      app.config[:sass_assets_paths].each do |path|
        compass_config.add_import_path path
      end

      # Disable this initially, the cache_buster extension will
      # re-enable it if requested.
      compass_config.asset_cache_buster { |_| nil }

      # Disable this initially, the relative_assets extension will

      compass_config.relative_assets = false

      # Default output style
      compass_config.output_style = :nested

      # No line-comments in test mode (changing paths mess with sha1)
      compass_config.line_comments = false if ENV['TEST']
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
