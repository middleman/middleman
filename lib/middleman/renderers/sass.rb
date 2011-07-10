require "sass"
require "sass/plugin"

module Middleman::Renderers::Sass
  class << self
    def registered(app)
      # Default sass options
      app.set :sass, {}
    end
    alias :included :registered
  end
  
  class SassPlusCSSFilenameTemplate < ::Tilt::SassTemplate
    def sass_options
      return super if basename.nil?

      location_of_sass_file = if Middleman::Server.environment == :build
        File.join(Middleman::Server.root, Middleman::Server.build_dir)
      else
        Middleman::Server.views
      end

      parts = basename.split('.')
      parts.pop
      css_filename = File.join(location_of_sass_file, Middleman::Server.css_dir, parts.join("."))
      super.merge(Middleman::Server.settings.sass).merge(:css_filename => css_filename)
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

# Use sass settings in Haml filters
# Other, tilt-based filters (like those used in Slim) will
# work automatically.
module Middleman::Renderers::Haml
  module Sass
    include ::Haml::Filters::Base

    def render(text)
      sass_options = Middleman::Server.settings.sass
      ::Sass::Engine.new(text, sass_options).render
    end
  end
end