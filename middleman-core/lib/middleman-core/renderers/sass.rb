# frozen_string_literal: true

require 'hamster'
require 'sassc'
require 'middleman-core/dependencies'
require 'middleman-core/dependencies/vertices/file_vertex'

module Middleman
  module Renderers
    # Sass renderer
    class Sass < ::Middleman::Extension
      DEFAULT_SASS_CACHE_LOCATION = './.sass-cache'

      opts = { output_style: :nested }
      opts[:line_comments] = false if ENV['TEST']
      define_setting :sass, opts, 'Sass engine options'
      define_setting :sass_assets_paths, [], 'Paths to extra SASS/SCSS files'
      define_setting :sass_source_maps, nil, 'Whether to inline sourcemap into Sass'
      define_setting :sass_cache_location, ENV['SASS_CACHE_LOCATION'] || DEFAULT_SASS_CACHE_LOCATION, 'Where to store sass cache files'

      # Setup extension
      def initialize(app, options_hash = ::Middleman::EMPTY_HASH, &block)
        super

        app.files.ignore :sass_cache, :source, %r{(^|/)\.sass-cache/} if app.config[:sass_cache_location] == DEFAULT_SASS_CACHE_LOCATION

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

          error_msg = <<~END
            /*
            #{header.gsub('*/', '*\\/')}

            Backtrace:\n#{e.backtrace.join("\n").gsub('*/', '*\\/')}
            */
            body:before {
              white-space: pre;
              font-family: monospace;
              content: "#{header.gsub('"', '\"').gsub("\n", '\\A ')}"; }
          END
          error_msg = error_msg.dup if error_msg.frozen? # slim will fail, if we pass frozen string as render result
          error_msg
        end

        def vertices
          @engine.dependencies.reduce(::Hamster::Set.empty) do |sum, d|
            sum << ::Middleman::Dependencies::FileVertex.new(@context.app.root_path, d.filename.to_sym)
          end
        rescue ::SassC::NotRenderedError
          ::Hamster::Set.empty
        end

        # Change Sass path, for url functions, to the build folder if we're building
        # @return [Hash]
        def sass_options
          ctx = @context

          preexisting_load_paths = begin
            ::Sass.load_paths
                                   rescue StandardError
                                     []
          end

          more_opts = {
            load_paths: preexisting_load_paths + ctx.app.config[:sass_assets_paths],
            filename: eval_file,
            line: line,
            syntax: syntax,
            cache_location: ctx.app.config[:sass_cache_location],
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

          more_opts[:css_filename] = file.sub(/\.s[ac]ss$/, '') if ctx.is_a?(::Middleman::TemplateContext) && file

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
