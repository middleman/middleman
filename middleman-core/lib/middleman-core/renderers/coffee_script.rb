# Require gem
require "coffee_script"

module Middleman
  module Renderers

    # CoffeeScript Renderer
    module CoffeeScript

      # Setup extension
      class << self
        # Once registered
        def registered(app)
          app.before_configuration do
            template_extensions :coffee => :js
          end

          # Tell Tilt to use it as well (for inline scss blocks)
          ::Tilt.register 'coffee', DebuggingCoffeeScriptTemplate
          ::Tilt.prefer(DebuggingCoffeeScriptTemplate)
        end
        alias :included :registered
      end

      # A Template for Tilt which outputs debug messages
      class DebuggingCoffeeScriptTemplate < ::Tilt::CoffeeScriptTemplate
        # Add exception messaging
        # @param [Class] context
        # @param [Hash] locals
        # @return [String]
        def evaluate(context, locals, &block)
          return super if context.build?

          begin
            super
          rescue ::ExecJS::RuntimeError => e
            e.to_s
          rescue => e
            e.to_s
          end
        end
      end
    end
  end
end
