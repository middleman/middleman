# Require gem
require 'haml'

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

        options = @options.merge(:filename => eval_file, :line => line)
        @engine = ::Haml::Engine.new(data, options)
        output = @engine.render(scope, locals, &block)

        ::Middleman::Renderers::Haml.last_haml_scope = nil

        output
      end
    end

    # Haml Renderer
    module Haml
      mattr_accessor :last_haml_scope

      # Setup extension
      class << self
        # Once registered
        def registered(app)
          ::Tilt.prefer(::Middleman::Renderers::HamlTemplate, 'haml')

          app.before_configuration do
            template_extensions :haml => :html
          end

          # Add haml helpers to context
          ::Middleman::TemplateContext.send :include, ::Haml::Helpers
        end
        alias :included :registered
      end
    end
  end
end
