require 'syntax'

module Syntax

  # A simple implementation of an YAML lexer. It handles most cases. It is
  # not a validating lexer.
  class YAML < Tokenizer

    # Step through a single iteration of the tokenization process. This will
    # yield (potentially) many tokens, and possibly zero tokens.
    def step
      if bol?
        case
          when scan(/---(\s*.+)?$/)
            start_group :document, matched
          when scan(/(\s*)([a-zA-Z][-\w]*)(\s*):/)
            start_group :normal, subgroup(1)
            start_group :key, subgroup(2)
            start_group :normal, subgroup(3)
            start_group :punct, ":"
          when scan(/(\s*)-/)
            start_group :normal, subgroup(1)
            start_group :punct, "-"
          when scan(/\s*$/)
            start_group :normal, matched
          when scan(/#.*$/)
            start_group :comment, matched
          else
            append getch
        end
      else
        case
          when scan(/[\n\r]+/)
            start_group :normal, matched
          when scan(/[ \t]+/)
            start_group :normal, matched
          when scan(/!+(.*?^)?\S+/)
            start_group :type, matched
          when scan(/&\S+/)
            start_group :anchor, matched
          when scan(/\*\S+/)
            start_group :ref, matched
          when scan(/\d\d:\d\d:\d\d/)
            start_group :time, matched
          when scan(/\d\d\d\d-\d\d-\d\d\s\d\d:\d\d:\d\d(\.\d+)? [-+]\d\d:\d\d/)
            start_group :date, matched
          when scan(/['"]/)
            start_group :punct, matched
            scan_string matched
          when scan(/:\w+/)
            start_group :symbol, matched
          when scan(/[:]/)
            start_group :punct, matched
          when scan(/#.*$/)
            start_group :comment, matched
          when scan(/>-?/)
            start_group :punct, matched
            start_group :normal, scan(/.*$/)
            append getch until eos? || bol?
            return if eos?
            indent = check(/ */)
            start_group :string
            loop do
              line = check_until(/[\n\r]|\Z/)
              break if line.nil?
              if line.chomp.length > 0
                this_indent = line.chomp.match( /^\s*/ )[0]
                break if this_indent.length < indent.length
              end
              append scan_until(/[\n\r]|\Z/)
            end
          else
            start_group :normal, scan_until(/(?=$|#)/)
        end
      end
    end

    private

      def scan_string( delim )
        regex = /(?=[#{delim=="'" ? "" : "\\\\"}#{delim}])/
        loop do
          text = scan_until( regex )
          if text.nil?
            start_group :string, scan_until( /\Z/ )
            break
          else
            start_group :string, text unless text.empty?
          end

          case peek(1)
            when "\\"
              start_group :expr, scan(/../)
            else
              start_group :punct, getch
              break
          end
        end
      end

  end

  SYNTAX["yaml"] = YAML

end
