module Padrino
  module Helpers
    module OutputHelpers
      ##
      # Handler for Haml templates.
      #
      class HamlHandler < AbstractHandler
        ##
        # Returns true if the block is for Haml
        #
        def engine_matches?(block)
          template.block_is_haml?(block)
        end

        ##
        # Captures the html from a block of template code for this handler.
        #
        def capture_from_template(*args, &block)
          engine_matches?(block) ? template.capture_haml(*args, &block) : block.call(*args)
        end
      end
      OutputHelpers.register(:haml, HamlHandler)
    end
  end
end
