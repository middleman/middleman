module Middleman
  class PreviewServer
    # Validate user input
    class ServerInformationValidator
      # Validate the input
      #
      # @param [ServerInformation] information
      #   The information instance which holds information about the preview
      #   server settings
      #
      # @param [Array] checks
      #   A list of checks which should be evaluated
      def validate(information, checks)
        checks.each { |c| c.validate information }
      end
    end
  end
end
