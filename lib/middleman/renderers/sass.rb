require "sass"
require "compass"

class Middleman::Server
  def scss(template, options={}, locals={})
    options[:layout] = false
    render :scss, template, options, locals
  end

  after_feature_init do
    ::Compass.configuration do |config|
      config.cache_path            = File.join(self.root, ".sass-cache") # For sassc files
      config.project_path          = self.root
      config.sass_dir              = File.join(File.basename(self.views), self.css_dir)
      config.output_style          = :nested
      config.fonts_dir             = File.join(File.basename(self.public), self.fonts_dir)
      config.css_dir               = File.join(File.basename(self.public), self.css_dir)
      config.images_dir            = File.join(File.basename(self.public), self.images_dir)      
      config.http_images_path      = self.http_images_path rescue File.join(self.http_prefix || "/", self.images_dir)
      config.http_stylesheets_path = self.http_css_path rescue File.join(self.http_prefix || "/", self.css_dir)
      config.asset_cache_buster { false }
      
      config.add_import_path(config.sass_dir)
    end
    
    configure :build do
      ::Compass.configuration do |config|
        config.css_dir       = File.join(File.basename(self.build_dir), self.css_dir)
        config.images_dir    = File.join(File.basename(self.build_dir), self.images_dir)
      end
    end
  end
end

class Tilt::SassPlusCSSFilenameTemplate < Tilt::SassTemplate
  def sass_options
    location_of_sass_file = Middleman::Server.environment == :build ? 
                              File.join(Middleman::Server.root, Middleman::Server.build_dir) : 
                              Middleman::Server.public

    parts = basename.split('.')
    parts.pop
    css_filename = File.join(location_of_sass_file, Middleman::Server.css_dir, parts.join("."))
    super.merge(::Compass.configuration.to_sass_engine_options).merge(:css_filename => css_filename)
  end
end
Tilt.register 'sass', Tilt::SassPlusCSSFilenameTemplate
Middleman::Renderers.register(:sass, Tilt::SassPlusCSSFilenameTemplate)

class Tilt::ScssPlusCSSFilenameTemplate < Tilt::SassPlusCSSFilenameTemplate
  def sass_options
    super.merge(:syntax => :scss)
  end
end
Tilt.register 'scss', Tilt::ScssPlusCSSFilenameTemplate
Middleman::Renderers.register(:scss, Tilt::ScssPlusCSSFilenameTemplate)


module Middleman::Haml
  module Sass
    include ::Haml::Filters::Base

    def render(text)
      ::Sass::Engine.new(text, ::Compass.configuration.to_sass_engine_options).render
    end
  end
end