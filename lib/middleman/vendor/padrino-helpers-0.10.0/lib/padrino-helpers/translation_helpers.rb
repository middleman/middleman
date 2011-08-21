module Padrino
  module Helpers
    module TranslationHelpers
      ##
      # Delegates to I18n.translate with no additional functionality.
      #
      def translate(*args)
        I18n.translate(*args)
      end
      alias :t :translate

      ##
      # Delegates to I18n.localize with no additional functionality.
      #
      def localize(*args)
        I18n.localize(*args)
      end
      alias :l :localize
    end # TranslationHelpers
  end # Helpers
end # Padrino