# Require gem
require "haml"

module Middleman
  module Renderers

    # Haml Renderer
    module Haml

      # Setup extension
      class << self
        # Once registered
        def registered(app)
          app.before_configuration do
            template_extensions :haml => :html
          end

          # Add haml helpers to context
          app.send :include, ::Haml::Helpers

          # Setup haml helper paths
          app.ready do
            init_haml_helpers
          end
        end
        alias :included :registered
      end
    end
  end
end
