# Require gem
require 'haml'

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
    # Haml Renderer
    module Haml
      # Setup extension
      class << self
        # Once registered
        def registered(app)
          app.before_configuration do
            template_extensions haml: :html
          end

          # Add haml helpers to context
          app.send :include, ::Haml::Helpers

          # Setup haml helper paths
          app.ready do
            init_haml_helpers
          end
        end
        alias_method :included, :registered
      end
    end
  end
end
