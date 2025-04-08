# ERb renderer
module Middleman
  module Renderers
    class ERb < ::Middleman::Extension
      def after_configuration
        ::Tilt.prefer(Template, :erb)
      end

      class Template < ::Tilt::ErubiTemplate
        def initialize(*args, &block)
          super

          @context = @options[:context]
        end

        ##
        # In preamble we need a flag `__in_erb_template` for padrino apps.
        #
        def precompiled_preamble(locals)
          original = super
          "__in_erb_template = true\n" << original
        end

        ##
        # Force the template the use the configured encoding.
        #
        def precompiled_template(locals)
          if @context
            super.dup.force_encoding(@context.app.config[:encoding])
          else
            super
          end
        end
      end
    end
  end
end
