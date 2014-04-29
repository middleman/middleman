# ERb renderer
module Middleman
  module Renderers
    module ERb
      # Setup extension
      class << self
        # once registered
        def registered(app)
          app.before_configuration do
            template_extensions erb: :html
          end

          # After config
          app.after_configuration do
            ::Tilt.prefer(Template, :erb)
          end
        end
        alias_method :included, :registered
      end

      class Template < ::Tilt::ErubisTemplate
        ##
        # In preamble we need a flag `__in_erb_template` and SafeBuffer for padrino apps.
        #
        def precompiled_preamble(locals)
          original = super
          "__in_erb_template = true\n" << original
          # .rpartition("\n").first << "#{@outvar} = _buf = ActiveSupport::SafeBuffer.new\n"
        end
      end
    end
  end
end
