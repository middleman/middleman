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
          # Default stylus options
          app.config.define_setting :styl, {}, 'Stylus config options'


          app.before_configuration do
            template_extensions :styl => :css
          end
        end

        alias :included :registered
      end

    end
  end
end
