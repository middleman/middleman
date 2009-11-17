require 'syntax'

module Syntax

  # A simple implementation of an XML lexer. It handles most cases. It is
  # not a validating lexer, meaning it will happily process invalid XML without
  # complaining.
  class XML < Tokenizer

    # Initialize the lexer.
    def setup
      @in_tag = false
    end

    # Step through a single iteration of the tokenization process. This will
    # yield (potentially) many tokens, and possibly zero tokens.
    def step
      start_group :normal, matched if scan( /\s+/ )
      if @in_tag
        case
          when scan( /([-\w]+):([-\w]+)/ )
            start_group :namespace, subgroup(1)
            start_group :punct, ":"
            start_group :attribute, subgroup(2)
          when scan( /\d+/ )
            start_group :number, matched
          when scan( /[-\w]+/ )
            start_group :attribute, matched
          when scan( %r{[/?]?>} )
            @in_tag = false
            start_group :punct, matched
          when scan( /=/ )
            start_group :punct, matched
          when scan( /["']/ )
            scan_string matched
          else
            append getch
        end
      elsif ( text = scan_until( /(?=[<&])/ ) )
        start_group :normal, text unless text.empty?
        if scan(/<!--.*?(-->|\Z)/m)
          start_group :comment, matched
        else
          case peek(1)
            when "<"
              start_group :punct, getch
              case peek(1)
                when "?"
                  append getch
                when "/"
                  append getch
                when "!"
                  append getch
              end
              start_group :normal, matched if scan( /\s+/ )
              if scan( /([-\w]+):([-\w]+)/ )
                start_group :namespace, subgroup(1)
                start_group :punct, ":"
                start_group :tag, subgroup(2)
              elsif scan( /[-\w]+/ )
                start_group :tag, matched
              end
              @in_tag = true
            when "&"
              if scan( /&\S{1,10};/ )
                start_group :entity, matched
              else
                start_group :normal, scan( /&/ )
              end
          end
        end
      else
        append scan_until( /\Z/ )
      end
    end

    private

      # Scan the string starting at the current position, with the given
      # delimiter character.
      def scan_string( delim )
        start_group :punct, delim
        match = /(?=[&\\]|#{delim})/
        loop do
          break unless ( text = scan_until( match ) )
          start_group :string, text unless text.empty?
          case peek(1)
            when "&"
              if scan( /&\S{1,10};/ )
                start_group :entity, matched
              else
                start_group :string, getch
              end
            when "\\"
              start_group :string, getch
              append getch || ""
            when delim
              start_group :punct, getch
              break
          end
        end
      end

  end

  SYNTAX["xml"] = XML

end
