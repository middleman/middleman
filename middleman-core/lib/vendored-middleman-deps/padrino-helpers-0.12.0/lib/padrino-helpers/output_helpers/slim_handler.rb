module Padrino
  module Helpers
    module OutputHelpers
      ##
      # Handler for Slim templates.
      #
      class SlimHandler < AbstractHandler
        ##
        # Returns true if the block is for Slim.
        #
        def engine_matches?(block)
          block.binding.eval('defined? __in_slim_template')
        end
      end
      OutputHelpers.register(:slim, SlimHandler)
    end
  end
end
