# ERb renderer
module Middleman
  module Renderers
    module ERb
      # Setup extension
      class << self

        # once registered
        def registered(app)
          # Setup a default ERb engine
          app.config.define_setting :erb_engine, :erb, 'The engine to use for rendering ERb templates'
          app.config.define_setting :erb_engine_prefix, ::Tilt, 'The parent module for ERb template engines'

          app.before_configuration do
            template_extensions :erb => :html
          end

          # After config
          app.after_configuration do
            # Find the user's prefered engine
            # Convert symbols to classes
            if config[:erb_engine].is_a? Symbol
              engine = engine.to_s
              engine = engine == "erb" ? "ERB" : engine.camelize
              config[:erb_engine] = config[:erb_engine_prefix].const_get("#{engine}Template")
            end

            # Tell Tilt to use the preferred engine
            ::Tilt.prefer(config[:erb_engine])
          end
        end
        alias :included :registered
      end
    end
  end
end
