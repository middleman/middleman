require 'syntax'

module Syntax

  # A tokenizer for the Ruby language. It recognizes all common syntax
  # (and some less common syntax) but because it is not a true lexer, it
  # will make mistakes on some ambiguous cases.
  class Ruby < Tokenizer

    # The list of all identifiers recognized as keywords.
    KEYWORDS =
      %w{if then elsif else end begin do rescue ensure while for
         class module def yield raise until unless and or not when
         case super undef break next redo retry in return alias
         defined?}

    # Perform ruby-specific setup
    def setup
      @selector = false
      @allow_operator = false
      @heredocs = []
    end

    # Step through a single iteration of the tokenization process.
    def step
      case
        when bol? && check( /=begin/ )
          start_group( :comment, scan_until( /^=end#{EOL}/ ) )
        when bol? && check( /__END__#{EOL}/ )
          start_group( :comment, scan_until( /\Z/ ) )
      else
        case
          when check( /def\s+/ )
            start_group :keyword, scan( /def\s+/ )
            start_group :method,  scan_until( /(?=[;(\s]|#{EOL})/ )
          when check( /class\s+/ )
            start_group :keyword, scan( /class\s+/ )
            start_group :class,  scan_until( /(?=[;\s<]|#{EOL})/ )
          when check( /module\s+/ )
            start_group :keyword, scan( /module\s+/ )
            start_group :module,  scan_until( /(?=[;\s]|#{EOL})/ )
          when check( /::/ )
            start_group :punct, scan(/::/)
          when check( /:"/ )
            start_group :symbol, scan(/:/)
            scan_delimited_region :symbol, :symbol, "", true
            @allow_operator = true
          when check( /:'/ )
            start_group :symbol, scan(/:/)
            scan_delimited_region :symbol, :symbol, "", false
            @allow_operator = true
          when scan( /:[_a-zA-Z@$][$@\w]*[=!?]?/ )
            start_group :symbol, matched
            @allow_operator = true
          when scan( /\?(\\[^\n\r]|[^\\\n\r\s])/ )
            start_group :char, matched
            @allow_operator = true
          when check( /(__FILE__|__LINE__|true|false|nil|self)[?!]?/ )
            if @selector || matched[-1] == ?? || matched[-1] == ?!
              start_group :ident,
                scan(/(__FILE__|__LINE__|true|false|nil|self)[?!]?/)
            else
              start_group :constant,
                scan(/(__FILE__|__LINE__|true|false|nil|self)/)
            end
            @selector = false
            @allow_operator = true
          when scan(/0([bB][01]+|[oO][0-7]+|[dD][0-9]+|[xX][0-9a-fA-F]+)/)
            start_group :number, matched
            @allow_operator = true
          else
            case peek(2)
              when "%r"
                scan_delimited_region :punct, :regex, scan( /../ ), true
                @allow_operator = true
              when "%w", "%q"
                scan_delimited_region :punct, :string, scan( /../ ), false
                @allow_operator = true
              when "%s"
                scan_delimited_region :punct, :symbol, scan( /../ ), false
                @allow_operator = true
              when "%W", "%Q", "%x"
                scan_delimited_region :punct, :string, scan( /../ ), true
                @allow_operator = true
              when /%[^\sa-zA-Z0-9]/
                scan_delimited_region :punct, :string, scan( /./ ), true
                @allow_operator = true
              when "<<"
                saw_word = ( chunk[-1,1] =~ /[\w!?]/ )
                start_group :punct, scan( /<</ )
                if saw_word
                  @allow_operator = false
                  return
                end

                float_right = scan( /-/ )
                append "-" if float_right
                if ( type = scan( /['"]/ ) )
                  append type
                  delim = scan_until( /(?=#{type})/ )
                  if delim.nil?
                    append scan_until( /\Z/ )
                    return
                  end
                else
                  delim = scan( /\w+/ ) or return
                end
                start_group :constant, delim
                start_group :punct, scan( /#{type}/ ) if type
                @heredocs << [ float_right, type, delim ]
                @allow_operator = true
              else
                case peek(1)
                  when /[\n\r]/
                    unless @heredocs.empty?
                      scan_heredoc(*@heredocs.shift)
                    else
                      start_group :normal, scan( /\s+/ )
                    end
                    @allow_operator = false
                  when /\s/
                    start_group :normal, scan( /\s+/ )
                  when "#"
                    start_group :comment, scan( /#[^\n\r]*/ )
                  when /[A-Z]/
                    start_group @selector ? :ident : :constant, scan( /\w+/ )
                    @allow_operator = true
                  when /[a-z_]/
                    word = scan( /\w+[?!]?/ )
                    if !@selector && KEYWORDS.include?( word )
                      start_group :keyword, word
                      @allow_operator = false
                    elsif
                      start_group :ident, word
                      @allow_operator = true
                    end
                    @selector = false
                  when /\d/
                    start_group :number,
                      scan( /[\d_]+(\.[\d_]+)?([eE][\d_]+)?/ )
                    @allow_operator = true
                  when '"'
                    scan_delimited_region :punct, :string, "", true
                    @allow_operator = true
                  when '/'
                    if @allow_operator
                      start_group :punct, scan(%r{/})
                      @allow_operator = false
                    else
                      scan_delimited_region :punct, :regex, "", true
                      @allow_operator = true
                    end
                  when "'"
                    scan_delimited_region :punct, :string, "", false
                    @allow_operator = true
                  when "."
                    dots = scan( /\.{1,3}/ )
                    start_group :punct, dots
                    @selector = ( dots.length == 1 )
                  when /[@]/
                    start_group :attribute, scan( /@{1,2}\w*/ )
                    @allow_operator = true
                  when /[$]/
                    start_group :global, scan(/\$/)
                    start_group :global, scan( /\w+|./ ) if check(/./)
                    @allow_operator = true
                  when /[-!?*\/+=<>(\[\{}:;,&|%]/
                    start_group :punct, scan(/./)
                    @allow_operator = false
                  when /[)\]]/
                    start_group :punct, scan(/./)
                    @allow_operator = true
                  else
                    # all else just falls through this, to prevent
                    # infinite loops...
                    append getch
                end
            end
        end
      end
    end

    private

      # Scan a delimited region of text. This handles the simple cases (strings
      # delimited with quotes) as well as the more complex cases of %-strings
      # and here-documents.
      #
      # * +delim_group+ is the group to use to classify the delimiters of the
      #   region
      # * +inner_group+ is the group to use to classify the contents of the
      #   region
      # * +starter+ is the text to use as the starting delimiter
      # * +exprs+ is a boolean flag indicating whether the region is an
      #   interpolated string or not
      # * +delim+ is the text to use as the delimiter of the region. If +nil+,
      #   the next character will be treated as the delimiter.
      # * +heredoc+ is either +false+, meaning the region is not a heredoc, or
      #   <tt>:flush</tt> (meaning the delimiter must be flushed left), or
      #   <tt>:float</tt> (meaning the delimiter doens't have to be flush left).
      def scan_delimited_region( delim_group, inner_group, starter, exprs,
        delim=nil, heredoc=false )
      # begin
        if !delim
          start_group delim_group, starter
          delim = scan( /./ )
          append delim

          delim = case delim
            when '{' then '}'
            when '(' then ')'
            when '[' then ']'
            when '<' then '>'
            else delim
          end
        end

        start_region inner_group

        items = "\\\\|"
        if heredoc
          items << "(^"
          items << '\s*' if heredoc == :float
          items << "#{Regexp.escape(delim)}\s*?)#{EOL}"
        else
          items << "#{Regexp.escape(delim)}"
        end
        items << "|#(\\$|@@?|\\{)" if exprs
        items = Regexp.new( items )

        loop do
          p = pos
          match = scan_until( items )
          if match.nil?
            start_group inner_group, scan_until( /\Z/ )
            break
          else
            text = pre_match[p..-1]
            start_group inner_group, text if text.length > 0
            case matched.strip
              when "\\"
                unless exprs
                  case peek(1)
                    when "'"
                      scan(/./)
                      start_group :escape, "\\'"
                    when "\\"
                      scan(/./)
                      start_group :escape, "\\\\"
                    else
                      start_group inner_group, "\\"
                  end
                else
                  start_group :escape, "\\"
                  c = getch
                  append c
                  case c
                    when 'x'
                      append scan( /[a-fA-F0-9]{1,2}/ )
                    when /[0-7]/
                      append scan( /[0-7]{0,2}/ )
                  end
                end
              when delim
                end_region inner_group
                start_group delim_group, matched
                break
              when /^#/
                do_highlight = (option(:expressions) == :highlight)
                start_region :expr if do_highlight
                start_group :expr, matched
                case matched[1]
                  when ?{
                    depth = 1
                    content = ""
                    while depth > 0
                      p = pos
                      c = scan_until( /[\{}]/ )
                      if c.nil?
                        content << scan_until( /\Z/ )
                        break
                      else
                        depth += ( matched == "{" ? 1 : -1 )
                        content << pre_match[p..-1]
                        content << matched if depth > 0
                      end
                    end
                    if do_highlight
                      subtokenize "ruby", content
                      start_group :expr, "}"
                    else
                      append content + "}"
                    end
                  when ?$, ?@
                    append scan( /\w+/ )
                end
                end_region :expr if do_highlight
              else raise "unexpected match on #{matched}"
            end
          end
        end
      end

      # Scan a heredoc beginning at the current position.
      #
      # * +float+ indicates whether the delimiter may be floated to the right
      # * +type+ is +nil+, a single quote, or a double quote
      # * +delim+ is the delimiter to look for
      def scan_heredoc(float, type, delim)
        scan_delimited_region( :constant, :string, "", type != "'",
          delim, float ? :float : :flush )
      end
  end

  SYNTAX["ruby"] = Ruby

end
