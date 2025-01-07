# Require gem
require 'coffee_script'

module Middleman
  module Renderers
    # CoffeeScript Renderer
    class CoffeeScript < ::Middleman::Extension
      # Setup extension
      def initialize(app, options={}, &block)
        super

        # Tell Tilt to use it as well (for inline scss blocks)
        ::Tilt.register 'coffee', DebuggingCoffeeScriptTemplate
        ::Tilt.prefer(DebuggingCoffeeScriptTemplate)

        DebuggingCoffeeScriptTemplate.middleman_app = app
      end

      # A Template for Tilt which outputs debug messages
      class DebuggingCoffeeScriptTemplate < ::Tilt::CoffeeScriptTemplate
        # Make the current Middleman app accessible to the template
        cattr_accessor :middleman_app

        def prepare
          return super unless middleman_app.server?

          @output = begin
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
