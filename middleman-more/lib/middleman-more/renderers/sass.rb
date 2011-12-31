# Pull in gems
require "sass"
require "sprockets"
require "sprockets-sass"

# Sass renderer
module Middleman::Renderers::Sass
  
  # Setup extension
  class << self
    
    # Once registered
    def registered(app)
      # Default sass options
      app.set :sass, {}
    end
    alias :included :registered
  end
  
  # A SassTemplate for Sprockets/Tilt which outputs debug messages
  class SassPlusCSSFilenameTemplate < ::Sprockets::Sass::SassTemplate
    
    # Add exception messaging
    # @param [Class] context
    # @param [Hash] locals
    # @return [String]
    def evaluate(context, locals, &block)
      begin
        super
      rescue Sass::SyntaxError => e
        Sass::SyntaxError.exception_to_css(e, :full_exception => true)
      end
    end
  
  protected
    # Change Sass path, for url functions, to the build folder if we're building
    # @return [Hash]
    def sass_options
      location_of_sass_file = if @context.build?
        File.expand_path(@context.build_dir, @context.root)
      else
        File.expand_path(@context.source, @context.root)
      end
      
      parts = basename.split('.')
      parts.pop
      css_filename = File.join(location_of_sass_file, @context.css_dir, parts.join("."))
      
      super.merge(:css_filename => css_filename)
    end
  end
  
  # Tell Sprockets to use our custom Sass template
  ::Sprockets.register_engine ".sass", SassPlusCSSFilenameTemplate
  
  # Tell Tilt to use it as well (for inline sass blocks)
  ::Tilt.register 'sass', SassPlusCSSFilenameTemplate
  ::Tilt.prefer(SassPlusCSSFilenameTemplate)
  
  # SCSS version of the above template
  class ScssPlusCSSFilenameTemplate < SassPlusCSSFilenameTemplate
    # Define the expected syntax for the template
    # @return [Symbol]
    def syntax
      :scss
    end
  end
  
  # Tell Sprockets to use our custom Scss template
  ::Sprockets.register_engine ".scss", ScssPlusCSSFilenameTemplate
  
  # Tell Tilt to use it as well (for inline scss blocks)
  ::Tilt.register 'scss', ScssPlusCSSFilenameTemplate
  ::Tilt.prefer(ScssPlusCSSFilenameTemplate)
end