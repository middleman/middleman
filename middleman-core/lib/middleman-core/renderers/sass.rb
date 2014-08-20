require 'sass'
require 'compass/import-once'

GLOB = /\*|\[.+\]/

# Hack around broken sass globs when combined with import-once
# Targets compass-import-once 1.0.4
# Tracking issue: https://github.com/chriseppstein/compass/issues/1529
module Compass
  module ImportOnce
    module Importer
      def find_relative(uri, base, options, *args)
        if uri =~ GLOB
          force_import = true
        else
          uri, force_import = handle_force_import(uri)
        end
        maybe_replace_with_dummy_engine(super(uri, base, options, *args), options, force_import)
      end

      def find(uri, options, *args)
        if uri =~ GLOB
          force_import = true
        else
          uri, force_import = handle_force_import(uri)
        end
        maybe_replace_with_dummy_engine(super(uri, options, *args), options, force_import)
      end
    end
  end
end

module Middleman
  module Renderers
    # Sass renderer
    module Sass
      # Setup extension
      class << self
        # Once registered
        def registered(app)
          # Default sass options
          app.config.define_setting :sass, {}, 'Sass engine options'

          app.before_configuration do
            template_extensions scss: :css,
                                sass: :css
          end

          # Tell Tilt to use it as well (for inline sass blocks)
          ::Tilt.register 'sass', SassPlusCSSFilenameTemplate
          ::Tilt.prefer(SassPlusCSSFilenameTemplate)

          # Tell Tilt to use it as well (for inline scss blocks)
          ::Tilt.register 'scss', ScssPlusCSSFilenameTemplate
          ::Tilt.prefer(ScssPlusCSSFilenameTemplate)

          ::Compass::ImportOnce.activate!
        end

        alias_method :included, :registered
      end

      # A SassTemplate for Tilt which outputs debug messages
      class SassPlusCSSFilenameTemplate < ::Tilt::SassTemplate
        def initialize(*args, &block)
          super

          @context = @options[:context] if @options.key?(:context)
        end

        # Define the expected syntax for the template
        # @return [Symbol]
        def syntax
          :sass
        end

        def prepare; end

        # Add exception messaging
        # @param [Class] context
        # @return [String]
        def evaluate(context, _)
          @context ||= context
          @engine = ::Sass::Engine.new(data, sass_options)

          begin
            @engine.render
          rescue ::Sass::SyntaxError => e
            ::Sass::SyntaxError.exception_to_css(e)
          end
        end

        # Change Sass path, for url functions, to the build folder if we're building
        # @return [Hash]
        def sass_options
          more_opts = { filename: eval_file, line: line, syntax: syntax }

          if @context.is_a?(::Middleman::Application) && file
            location_of_sass_file = @context.source_dir

            parts = basename.split('.')
            parts.pop
            more_opts[:css_filename] = File.join(location_of_sass_file, @context.config[:css_dir], parts.join('.'))
          end

          options.merge(more_opts)
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
