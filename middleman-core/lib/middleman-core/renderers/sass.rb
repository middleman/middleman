require 'sassc'

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
        # Define the expected syntax for the template
        # @return [Symbol]
        def syntax
          :sass
        end

        private

        # Add exception messaging
        # @param [Class] context
        # @return [String]
        def _prepare_output
          @context = @options[:context]
          @engine = ::SassC::Engine.new(data, sass_options)

          begin
            @engine.render
          rescue ::SassC::SyntaxError => e
            raise e if @context.app.build?

            exception_to_css(e)
          end
        end

        def exception_to_css(e)
          header = "#{e.class}: #{e.message}"

          <<~END
            /*
            #{header.gsub('*/', '*\\/')}

            Backtrace:\n#{e.backtrace.join("\n").gsub('*/', '*\\/')}
            */
            body:before {
              white-space: pre;
              font-family: monospace;
              content: "#{header.gsub('"', '\"').gsub("\n", '\\A ')}"; }
          END
        end

        # Change Sass path, for url functions, to the build folder if we're building
        # @return [Hash]
        def sass_options
          ctx = @context

          preexisting_load_paths = begin
            ::Sass.load_paths
          rescue
            []
          end

          more_opts = {
            load_paths: preexisting_load_paths + ctx.app.config[:sass_assets_paths],
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
