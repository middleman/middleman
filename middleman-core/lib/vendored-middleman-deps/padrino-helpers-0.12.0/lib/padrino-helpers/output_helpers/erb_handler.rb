module Padrino
  module Helpers
    module OutputHelpers
      ##
      # Handler for Erb template.
      #
      class ErbHandler < AbstractHandler
        ##
        # Outputs the given text to the templates buffer directly.
        #
        def concat_to_template(text="")
          output_buffer << text
          nil
        end

        ##
        # Returns true if the block is Erb.
        #
        def engine_matches?(block)
          block.binding.eval('defined? __in_erb_template')
        end
      end
      OutputHelpers.register(:erb, ErbHandler)
      OutputHelpers.register(:erubis, ErbHandler)
    end
  end
end
