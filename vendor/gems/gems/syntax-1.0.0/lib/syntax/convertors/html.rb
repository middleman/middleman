require 'syntax/convertors/abstract'

module Syntax
  module Convertors

    # A simple class for converting a text into HTML.
    class HTML < Abstract

      # Converts the given text to HTML, using spans to represent token groups
      # of any type but <tt>:normal</tt> (which is always unhighlighted). If
      # +pre+ is +true+, the html is automatically wrapped in pre tags.
      def convert( text, pre=true )
        html = ""
        html << "<pre>" if pre
        regions = []
        @tokenizer.tokenize( text ) do |tok|
          value = html_escape(tok)
          case tok.instruction
            when :region_close then
              regions.pop
              html << "</span>"
            when :region_open then
              regions.push tok.group
              html << "<span class=\"#{tok.group}\">#{value}"
            else
              if tok.group == ( regions.last || :normal )
                html << value
              else
                html << "<span class=\"#{tok.group}\">#{value}</span>"
              end
          end
        end
        html << "</span>" while regions.pop
        html << "</pre>" if pre
        html
      end

      private

        # Replaces some characters with their corresponding HTML entities.
        def html_escape( string )
          string.gsub( /&/, "&amp;" ).
                 gsub( /</, "&lt;" ).
                 gsub( />/, "&gt;" ).
                 gsub( /"/, "&quot;" )
        end

    end

  end
end
