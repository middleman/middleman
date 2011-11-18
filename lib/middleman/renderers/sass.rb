require "sprockets"
require "sprockets-sass"
require "sass"

module Middleman::Renderers::Sass
  class << self
    def registered(app)
      # Default sass options
      app.set :sass, {}
    end
    alias :included :registered
  end

  class SassPlusCSSFilenameTemplate < ::Sprockets::Sass::SassTemplate
    self.default_mime_type = "text/css"
    
    # Add exception messaging
    def evaluate(context, locals, &block)
      begin
        super
      rescue Sass::SyntaxError => e
        Sass::SyntaxError.exception_to_css(e, :full_exception => true)
      end
    end
  
  protected
    def sass_options
      location_of_sass_file = if @context.build?
        File.expand_path(@context.build_dir, @context.root)
      else
        File.expand_path(@context.views, @context.root)
      end
      
      parts = basename.split('.')
      parts.pop
      css_filename = File.join(location_of_sass_file, @context.css_dir, parts.join("."))
      
      super.merge(
        :css_filename => css_filename
      )
    end
  end
  ::Sprockets.register_engine ".sass", SassPlusCSSFilenameTemplate
  ::Tilt.register 'sass', SassPlusCSSFilenameTemplate
  ::Tilt.prefer(SassPlusCSSFilenameTemplate)
  
  class ScssPlusCSSFilenameTemplate < SassPlusCSSFilenameTemplate
    self.default_mime_type = "text/css"
    
    # Define the expected syntax for the template
    def syntax
      :scss
    end
  end
  
  ::Sprockets.register_engine ".scss", ScssPlusCSSFilenameTemplate
  ::Tilt.register 'scss', ScssPlusCSSFilenameTemplate
  ::Tilt.prefer(ScssPlusCSSFilenameTemplate)
end