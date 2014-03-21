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
        end

        alias :included :registered
      end

    end
  end
end
