# ERb renderer
module Middleman
  module Renderers
    class ERb < ::Middleman::Extension
      def after_configuration
        ::Tilt.prefer(Template, :erb)
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
