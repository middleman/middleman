module Padrino
  module Helpers
    ##
    # Helpers related to locale1 i18n translation within templates.
    #
    module TranslationHelpers
      ##
      # Delegates to I18n.translate with no additional functionality.
      #
      # @param [Symbol] *args
      #   The keys to retrieve.
      #
      # @return [String]
      #  The translation for the specified keys.
      #
      # @api public
      def translate(*args)
        I18n.translate(*args)
      end
      alias :t :translate

      ##
      # Delegates to I18n.localize with no additional functionality.
      #
      # @param [Symbol] *args
      #   The keys to retrieve.
      #
      # @return [String]
      #  The translation for the specified keys.
      #
      # @api public
      def localize(*args)
        I18n.localize(*args)
      end
      alias :l :localize
    end # TranslationHelpers
  end # Helpers
end # Padrino
