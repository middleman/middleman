require "sass"
require "sass/plugin"
require "compass"

module Middleman::Renderers::Sass
  class << self
    def registered(app)
      # Susy grids
      begin
        require "susy"
      rescue LoadError
      end
      
      app.after_feature_init do
        views_root = File.basename(app.views)
        ::Compass.configuration do |config|
          config.cache            = false # For sassc files
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

        # configure :build do
        #   build_root = File.basename(self.build_dir)
        #   ::Compass.configuration do |config|
        #     config.css_dir    = File.join(build_root, self.css_dir)
        #     config.images_dir = File.join(build_root, self.images_dir)
        #   end
        # end
      end
    end
    alias :included :registered
  end
  
  class SassPlusCSSFilenameTemplate < ::Tilt::SassTemplate
    def sass_options
      return super if basename.nil?

      location_of_sass_file = Middleman::Server.environment == :build ? 
                                File.join(Middleman::Server.root, Middleman::Server.build_dir) : 
                                Middleman::Server.views

      parts = basename.split('.')
      parts.pop
      css_filename = File.join(location_of_sass_file, Middleman::Server.css_dir, parts.join("."))
      super.merge(::Compass.configuration.to_sass_engine_options).merge(:css_filename => css_filename)
    end

    def evaluate(scope, locals, &block)
      begin
        super
      rescue Sass::SyntaxError => e
        Sass::SyntaxError.exception_to_css(e, :full_exception => true)
      end
    end
  end
  ::Tilt.register 'sass', SassPlusCSSFilenameTemplate
  ::Tilt.prefer(SassPlusCSSFilenameTemplate)

  class ScssPlusCSSFilenameTemplate < SassPlusCSSFilenameTemplate
    def sass_options
      super.merge(:syntax => :scss)
    end
  end
  ::Tilt.register 'scss', ScssPlusCSSFilenameTemplate
  ::Tilt.prefer(ScssPlusCSSFilenameTemplate)
end

# Use compass settings in Haml filters
# Other, tilt-based filters (like those used in Slim) will
# work automatically.
module Middleman::Renderers::Haml
  module Sass
    include ::Haml::Filters::Base

    def render(text)
      compass_options = ::Compass.configuration.to_sass_engine_options
      ::Sass::Engine.new(text, compass_options).render
    end
  end
end