# ERb renderer
module Middleman
  module Renderers
    class ERb < ::Middleman::Extension
      def after_configuration
        ::Tilt.prefer(Template, :erb)
      end

      class Template < ::Tilt::ErubiTemplate
        ##
        # In preamble we need a flag `__in_erb_template` for padrino apps.
        #
        def precompiled_preamble(locals)
          original = super
          "__in_erb_template = true\n" << original
        end
      end
    end
  end
end
