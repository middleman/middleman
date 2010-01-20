module Templater
  module Actions
    class Directory < File
  
      # Returns empty string
      #
      # === Returns
      # String:: Empty string.
      def render
        ""
      end
      
      # Checks if the content of the file at the destination is identical to the rendered result.
      # 
      # === Returns
      # Boolean:: true if it is identical, false otherwise.
      def identical?
        exists?
      end      
    end
  end
end
