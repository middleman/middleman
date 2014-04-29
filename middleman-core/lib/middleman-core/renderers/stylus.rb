require 'stylus'
require 'stylus/tilt'

module Middleman
  module Renderers
    # Sass renderer
    module Stylus
      # Setup extension
      class << self
        # Once registered
        def registered(app)
          # Default less options
          app.set :styl, {}

          app.before_configuration do
            template_extensions styl: :css
          end
        end

        alias_method :included, :registered
      end
    end
  end
end
