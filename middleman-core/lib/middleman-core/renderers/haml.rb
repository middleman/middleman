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
      def prepare
      end

      def evaluate(scope, locals, &block)
        ::Middleman::Renderers::Haml.last_haml_scope = scope

        options = @options.merge(filename: eval_file, line: line)
        @engine = ::Haml::Engine.new(data, options)
        output = @engine.render(scope, locals, &block)

        ::Middleman::Renderers::Haml.last_haml_scope = nil

        output
      end
    end

    # Haml Renderer
    class Haml < ::Middleman::Extension
      cattr_accessor :last_haml_scope

      def initialize(app, options={}, &block)
        super

        ::Tilt.prefer(::Middleman::Renderers::HamlTemplate, :haml)

        # Add haml helpers to context
        ::Middleman::TemplateContext.send :include, ::Haml::Helpers
      end
    end
  end
end
