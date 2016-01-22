require 'sass'

begin
  require 'sassc'
rescue LoadError
end

module Middleman
  module Renderers
    # Sass renderer
    class Sass < ::Middleman::Extension
      opts = { output_style: :nested }
      opts[:line_comments] = false if ENV['TEST']
      define_setting :sass, opts, 'Sass engine options'
      define_setting :sass_assets_paths, [], 'Paths to extra SASS/SCSS files'
      define_setting :sass_source_maps, nil, 'Whether to inline sourcemap into Sass'

      # Setup extension
      def initialize(app, options={}, &block)
        super

        logger.info '== Preferring use of LibSass' if defined?(::SassC)

        app.files.ignore :sass_cache, :source, /(^|\/)\.sass-cache\//

        # Tell Tilt to use it as well (for inline sass blocks)
        ::Tilt.register 'sass', SassPlusCSSFilenameTemplate
        ::Tilt.prefer(SassPlusCSSFilenameTemplate)

        # Tell Tilt to use it as well (for inline scss blocks)
        ::Tilt.register 'scss', ScssPlusCSSFilenameTemplate
        ::Tilt.prefer(ScssPlusCSSFilenameTemplate)

        require 'middleman-core/renderers/sass_functions'
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

          sass_module = if defined?(::SassC)
            ::SassC
          else
            ::Sass
          end

          @engine = sass_module::Engine.new(data, sass_options)

          begin
            @engine.render
          rescue sass_module::SyntaxError => e
            ::Sass::SyntaxError.exception_to_css(e)
          end
        end

        # Change Sass path, for url functions, to the build folder if we're building
        # @return [Hash]
        def sass_options
          ctx = @context

          more_opts = {
            load_paths: ::Sass.load_paths | ctx.app.config[:sass_assets_paths],
            filename: eval_file,
            line: line,
            syntax: syntax,
            custom: {}.merge!(options[:custom] || {}).merge!(
              middleman_context: ctx.app,
              current_resource: ctx.current_resource
            )
          }

          if ctx.app.config[:sass_source_maps] || (ctx.app.config[:sass_source_maps].nil? && ctx.app.development?)
            more_opts[:source_map_file] = '.'
            more_opts[:source_map_embed] = true
            more_opts[:source_map_contents] = true
          end

          if ctx.is_a?(::Middleman::TemplateContext) && file
            more_opts[:css_filename] = file.sub(/\.s[ac]ss$/, '')
          end

          {}.merge!(options).merge!(more_opts)
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
