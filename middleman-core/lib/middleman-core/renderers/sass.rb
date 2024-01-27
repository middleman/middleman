require 'addressable/uri'
require 'sass-embedded'

module Middleman
  module Renderers
    # Sass renderer
    class Sass < ::Middleman::Extension
      define_setting :sass, {}, 'Sass options'
      define_setting :sass_assets_paths, [], 'Paths to extra SASS/SCSS files'
      define_setting :sass_source_maps, nil, 'Whether to inline sourcemap into Sass'

      # Setup extension
      def initialize(app, options={}, &block)
        super

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
          :indented
        end

        def prepare; end

        # Add exception messaging
        # @param [Class] context
        # @return [String]
        def evaluate(context, _)
          @context ||= context

          begin
            result = ::Sass.compile_string(data, **sass_options)
            if result.source_map
              source_mapping_url = "data:application/json;base64,#{[result.source_map].pack('m0')}"
              result.css + "\n\n/*# sourceMappingURL=#{source_mapping_url} */"
            else
              result.css + "\n"
            end
          rescue ::Sass::CompileError => e
            raise e if @context.app.build?

            +e.to_css
          end
        end


        # Change Sass path, for url functions, to the build folder if we're building
        # @return [Hash]
        def sass_options
          ctx = @context

          sass_options = {}.merge!(ctx.app.config[:sass])
          sass_options[:load_paths] = [].concat(sass_options[:load_paths] || []).concat(ctx.app.config[:sass_assets_paths] || [])
          sass_options[:syntax] = syntax
          sass_options[:url] = Addressable::URI.convert_path(eval_file)
          sass_options[:style] = options[:style] if options.key?(:style)

          if ctx.app.config[:sass_source_maps] || (ctx.app.config[:sass_source_maps].nil? && ctx.app.development?)
            %i[source_map source_map_include_sources].each do |option|
              sass_options[option] = true if sass_options[option].nil?
            end
          end

          custom_options = {
            custom: {}.merge!(options[:custom] || {}).merge!(
              middleman_context: ctx.app,
              current_resource: ctx.current_resource
            )
          }

          functions_options = {}.merge!(options).merge!(sass_options).merge!(custom_options)

          sass_options[:functions] = {}.merge!(sass_options[:functions] || {}).merge!(
            functions(::Middleman::Sass::Functions, functions_options)
          )

          sass_options
        end

        private

        # Convert Ruby functions module to Sass functions hash
        def functions(functions_module, functions_options)
          functions_wrapper = Class.new do
            attr_reader :options

            include functions_module

            def initialize(options)
              @options = options
            end
          end.new(functions_options)

          functions_module.public_instance_methods.to_h do |function_name|
            ["#{function_name}($args...)", lambda do |args|
              functions_wrapper.send(function_name, *args[0].to_a, args[0].keywords)
            end]
          end
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
