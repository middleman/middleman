require "sass"

module Middleman
  module Renderers
    
    # Sass renderer
    module Sass
  
      # Setup extension
      class << self
    
        # Once registered
        def registered(app)
          # Default sass options
          app.set :sass, {}
      
          # Location of SASS .sass_cache directory.
          # @return [String]
          #   set :sass_cache_path, "/tmp/middleman-app-name/sass_cache"
          app.set(:sass_cache_path) { File.join(app.root_path, '.sass_cache') } # runtime compile of path
      
          app.before_configuration do
            template_extensions :scss => :css,
                                :sass => :css
          end

          # Tell Tilt to use it as well (for inline sass blocks)
          ::Tilt.register 'sass', SassPlusCSSFilenameTemplate
          ::Tilt.prefer(SassPlusCSSFilenameTemplate)

          # Tell Tilt to use it as well (for inline scss blocks)
          ::Tilt.register 'scss', ScssPlusCSSFilenameTemplate
          ::Tilt.prefer(ScssPlusCSSFilenameTemplate)
        end
    
        alias :included :registered
      end
  
      # A SassTemplate for Tilt which outputs debug messages
      class SassPlusCSSFilenameTemplate < ::Tilt::SassTemplate
  
        # Define the expected syntax for the template
        # @return [Symbol]
        def syntax
          :sass
        end
          
        def prepare; end

        # Add exception messaging
        # @param [Class] context
        # @param [Hash] locals
        # @return [String]
        def evaluate(context, locals, &block)
          @context = context
          @engine = ::Sass::Engine.new(data, sass_options)
          
          begin
            @engine.render
          rescue ::Sass::SyntaxError => e
            ::Sass::SyntaxError.exception_to_css(e, :full_exception => true)
          end
        end
  
      private
        # Change Sass path, for url functions, to the build folder if we're building
        # @return [Hash]
        def sass_options
          location_of_sass_file = File.expand_path(@context.source, @context.root)
      
          parts = basename.split('.')
          parts.pop
          css_filename = File.join(location_of_sass_file, @context.css_dir, parts.join("."))
      
          options.merge(:filename => eval_file, :line => line, :syntax => syntax, :css_filename => css_filename)
        end
      end
  
      # SCSS version of the above template
      class ScssPlusCSSFilenameTemplate < SassPlusCSSFilenameTemplate
    
        # Define the expected syntax for the template
        # @return [Symbol]
        def syntax
          :scss
        end
      end
    end
  end
end