# Require gem
require 'haml'

# Require padrino-helpers now so that we get a chance to replace their renderer with ours in Tilt.
require 'padrino-helpers'

module SafeTemplate
  def render(*)
    super.html_safe
  end
end

class Tilt::HamlTemplate
  include SafeTemplate
end

module Middleman
  module Renderers
    # Haml precompiles filters before the scope is even available,
    # thus making it impossible to pass our Middleman instance
    # in. So we have to resort to heavy hackery :(
    class HamlTemplate < ::Tilt::HamlTemplate
      def initialize(*args, &block)
        super

        @context = @options[:context] if @options.key?(:context)
      end

      def prepare; end

      def evaluate(scope, locals, &block)
        options = {}.merge!(@options).merge!(context: @context || scope)
        if options.include?(:outvar)
          options[:buffer] = options.delete(:outvar)
          options[:save_buffer] = true
        end
        if Object.const_defined?('::Haml::Template') # haml 6+
          @engine = ::Haml::Template.new(eval_file, line, options) { data }
        else
          options[:filename] = eval_file
          options[:line] = line
          @engine = ::Haml::Engine.new(data, options)
        end
        output = @engine.render(scope, locals, &block)

        output
      end
    end

    # Haml Renderer
    class Haml < ::Middleman::Extension
      def initialize(app, options={}, &block)
        super

        if Object.const_defined?('::Haml::Options') # Haml 5 and older
          ::Haml::Options.defaults[:context] = nil
          ::Haml::Options.send :attr_accessor, :context
        else # Haml 6+
          ::Haml::Engine.define_options context: nil
        end
        if defined?(::Haml::TempleEngine)
          ::Haml::TempleEngine.define_options context: nil
        end

        # rubocop:disable NestedMethodDefinition
        [::Haml::Filters::Sass, ::Haml::Filters::Scss, ::Haml::Filters::Markdown].each do |f|
          f.class_exec do
            if respond_to?(:template_class) # Haml 5 and older
              def self.render_with_options(text, compiler_options)
                modified_options = options.dup
                modified_options[:context] = compiler_options[:context]

                text = template_class.new(nil, 1, modified_options) { text }.render
                super(text, compiler_options)
              end
            else # Haml 6+
              def initialize(options = {})
                super
                @context = options[:context]
              end

              def compile_with_tilt(node, name, indent_width: 0)
                options = { context: @context }
                source = node.value[:text]
                result = ::Tilt["t.#{name}"].new(nil, 1, options) { source }.render

                temple = [:multi, [:static, result.gsub(/^/, ' ' * indent_width)]]
                source.lines.size.times do
                  temple << [:newline]
                end
                temple
              end
            end
          end
        end
        # rubocop:enable NestedMethodDefinition

        ::Tilt.prefer(::Middleman::Renderers::HamlTemplate, :haml)

        # Add haml helpers to context
        ::Middleman::TemplateContext.send :include, ::Haml::Helpers
      end

      def add_exposed_to_context(context)
        super

        context.init_haml_helpers if context.respond_to?(:init_haml_helpers)
      end
    end
  end
end
