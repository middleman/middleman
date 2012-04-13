module Padrino
  module Helpers
    ###
    # Helpers related to formatting or manipulating text within templates.
    #
    module FormatHelpers
      ##
      # Returns escaped text to protect against malicious content
      #
      # @param [String] text
      #   Unsanitized HTML string that needs to be escaped.
      #
      # @return [String] HTML with escaped characters.
      #
      # @example
      #   escape_html("<b>Hey<b>") => "&lt;b&gt;Hey&lt;b;gt;"
      #   h("Me & Bob") => "Me &amp; Bob"
      #
      # @api public
      def escape_html(text)
        Rack::Utils.escape_html(text)
      end
      alias h escape_html
      alias sanitize_html escape_html

      ##
      # Returns escaped text to protect against malicious content
      # Returns blank if the text is empty
      #
      # @param [String] text
      #   Unsanitized HTML string that needs to be escaped.
      # @param [String] blank_text
      #   Text to return if escaped text is blank.
      #
      # @return [String] HTML with escaped characters or the value specified if blank.
      #
      # @example
      #   h!("Me & Bob") => "Me &amp; Bob"
      #   h!("", "Whoops") => "Whoops"
      #
      # @api public
      def h!(text, blank_text = '&nbsp;')
        return blank_text if text.nil? || text.empty?
        h text
      end

      ##
      # Strips all HTML tags from the html
      #
      # @param [String] html
      #   The HTML for which to strip tags.
      #
      # @return [String] HTML with tags stripped.
      #
      # @example
      #   strip_tags("<b>Hey</b>") => "Hey"
      #
      # @api public
      def strip_tags(html)
        html.gsub(/<\/?[^>]*>/, "") if html
      end

      ##
      # Returns text transformed into HTML using simple formatting rules. Two or more consecutive newlines(\n\n) are considered
      # as a paragraph and wrapped in <p> or your own tags. One newline (\n) is considered as a linebreak and a <br /> tag is appended.
      # This method does not remove the newlines from the text.
      #
      # @param [String] text
      #   The simple text to be formatted.
      # @param [Hash] options
      #   Formatting options for the text. Can accept html options for the wrapper tag.
      # @option options [Symbol] :tag (p)
      #   The html tag to use for formatting newlines.
      #
      # @return [String] The text formatted as simple HTML.
      #
      # @example
      #   simple_format("hello\nworld") # => "<p>hello<br/>world</p>"
      #   simple_format("hello\nworld", :tag => :div, :class => :foo) # => "<div class="foo">hello<br/>world</div>"
      #
      # @api public
      def simple_format(text, options={})
        t = options.delete(:tag) || :p
        start_tag = tag(t, options, true)
        text = text.to_s.dup
        text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
        text.gsub!(/\n\n+/, "</#{t}>\n\n#{start_tag}")  # 2+ newline  -> paragraph
        text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
        text.insert 0, start_tag
        text << "</#{t}>"
      end

      ##
      # Attempts to pluralize the singular word unless count is 1. If plural is supplied, it will use that when count is > 1,
      # otherwise it will use the Inflector to determine the plural form
      #
      # @param [Fixnum] count
      #   The count which determines pluralization.
      # @param [String] singular
      #   The word to be pluralized if appropriate based on +count+.
      # @param [String] plural
      #   Explicit pluralized word to be used; if not specified uses inflector.
      #
      # @return [String] The properly pluralized word.
      #
      # @example
      #   pluralize(2, 'person') => '2 people'
      #
      # @api public
      def pluralize(count, singular, plural = nil)
        "#{count || 0} " + ((count == 1 || count == '1') ? singular : (plural || singular.pluralize))
      end

      ##
      # Truncates a given text after a given :length if text is longer than :length (defaults to 30).
      # The last characters will be replaced with the :omission (defaults to "…") for a total length not exceeding :length.
      #
      # @param [String] text
      #   The text to be truncated.
      # @param [Hash] options
      #   Formatting options for the truncation.
      # @option options [Fixnum] :length (30)
      #   The number of characters before truncation occurs.
      # @option options [String] :omission ("...")
      #   The characters that are placed after the truncated text.
      #
      # @return [String] The text truncated after the given number of characters.
      #
      # @example
      #   truncate("Once upon a time in a world far far away", :length => 8) => "Once upon..."
      #
      # @api public
      def truncate(text, options={})
        options.reverse_merge!(:length => 30, :omission => "...")
        if text
          len = options[:length] - options[:omission].length
          chars = text
          (chars.length > options[:length] ? chars[0...len] + options[:omission] : text).to_s
        end
      end

      ##
      # Truncates words of a given text after a given :length if number of words in text is more than :length (defaults to 30).
      # The last words will be replaced with the :omission (defaults to "…") for a total number of words not exceeding :length.
      #
      # @param [String] text
      #   The text to be truncated.
      # @param [Hash] options
      #   Formatting options for the truncation.
      # @option options [Fixnum] :length (30)
      #   The number of words before truncation occurs.
      # @option options [String] :omission ("...")
      #   The characters that are placed after the truncated text.
      #
      # @return [String] The text truncated after the given number of words.
      #
      # @example
      #   truncate_words("Once upon a time in a world far far away", :length => 8) => "Once upon a time in a world far..."
      #
      # @api public
      def truncate_words(text, options={})
        options.reverse_merge!(:length => 30, :omission => "...")
        if text
          words = text.split()
          words[0..(options[:length]-1)].join(' ') + (words.length > options[:length] ? options[:omission] : '')
        end
      end

      ##
      # Wraps the text into lines no longer than line_width width.
      # This method breaks on the first whitespace character that does not exceed line_width (which is 80 by default).
      #
      # @overload word_wrap(text, options={})
      #   @param [String] text
      #     The text to be wrapped.
      #   @param [Hash] options
      #     Formatting options for the wrapping.
      #   @option options [Fixnum] :line_width (80)
      #     The line width before a wrap should occur.
      #
      # @return [String] The text with line wraps for lines longer then +line_width+
      #
      # @example
      #   word_wrap('Once upon a time', :line_width => 8) => "Once upon\na time"
      #
      # @api public
      def word_wrap(text, *args)
        options = args.extract_options!
        unless args.blank?
          options[:line_width] = args[0] || 80
        end
        options.reverse_merge!(:line_width => 80)

        text.split("\n").map do |line|
          line.length > options[:line_width] ? line.gsub(/(.{1,#{options[:line_width]}})(\s+|$)/, "\\1\n").strip : line
        end * "\n"
      end

      ##
      # Highlights one or more words everywhere in text by inserting it into a :highlighter string.
      #
      # The highlighter can be customized by passing :+highlighter+ as a single-quoted string
      # with \1 where the phrase is to be inserted.
      #
      # @overload highlight(text, words, options={})
      #   @param [String] text
      #     The text that will be searched.
      #   @param [String] words
      #     The words to be highlighted in the +text+.
      #   @param [Hash] options
      #     Formatting options for the highlight.
      #   @option options [String] :highlighter ('<strong class="highlight">\1</strong>')
      #     The html pattern for wrapping the highlighted words.
      #
      # @return [String] The text with the words specified wrapped with highlighted spans.
      #
      # @example
      #   highlight('Lorem ipsum dolor sit amet', 'dolor')
      #   # => Lorem ipsum <strong class="highlight">dolor</strong> sit amet
      #
      #   highlight('Lorem ipsum dolor sit amet', 'dolor', :highlighter => '<span class="custom">\1</span>')
      #   # => Lorem ipsum <strong class="custom">dolor</strong> sit amet
      #
      # @api public
      def highlight(text, words, *args)
        options = args.extract_options!
        options.reverse_merge!(:highlighter => '<strong class="highlight">\1</strong>')

        if text.blank? || words.blank?
          text
        else
          match = Array(words).map { |p| Regexp.escape(p) }.join('|')
          text.gsub(/(#{match})(?!(?:[^<]*?)(?:["'])[^<>]*>)/i, options[:highlighter])
        end
      end

      ##
      # Reports the approximate distance in time between two Time or Date objects or integers as seconds.
      # Set +include_seconds+ to true if you want more detailed approximations when distance < 1 min, 29 secs
      # Distances are reported based on the following table:
      #
      #   0 <-> 29 secs                                                             # => less than a minute
      #   30 secs <-> 1 min, 29 secs                                                # => 1 minute
      #   1 min, 30 secs <-> 44 mins, 29 secs                                       # => [2..44] minutes
      #   44 mins, 30 secs <-> 89 mins, 29 secs                                     # => about 1 hour
      #   89 mins, 29 secs <-> 23 hrs, 59 mins, 29 secs                             # => about [2..24] hours
      #   23 hrs, 59 mins, 29 secs <-> 47 hrs, 59 mins, 29 secs                     # => 1 day
      #   47 hrs, 59 mins, 29 secs <-> 29 days, 23 hrs, 59 mins, 29 secs            # => [2..29] days
      #   29 days, 23 hrs, 59 mins, 30 secs <-> 59 days, 23 hrs, 59 mins, 29 secs   # => about 1 month
      #   59 days, 23 hrs, 59 mins, 30 secs <-> 1 yr minus 1 sec                    # => [2..12] months
      #   1 yr <-> 1 yr, 3 months                                                   # => about 1 year
      #   1 yr, 3 months <-> 1 yr, 9 months                                         # => over 1 year
      #   1 yr, 9 months <-> 2 yr minus 1 sec                                       # => almost 2 years
      #   2 yrs <-> max time or date                                                # => (same rules as 1 yr)
      #
      # With +include_seconds+ = true and the difference < 1 minute 29 seconds:
      #   0-4   secs      # => less than 5 seconds
      #   5-9   secs      # => less than 10 seconds
      #   10-19 secs      # => less than 20 seconds
      #   20-39 secs      # => half a minute
      #   40-59 secs      # => less than a minute
      #   60-89 secs      # => 1 minute
      #
      # @param [Time] from_time
      #   The time to be compared against +to_time+ in order to approximate the distance.
      # @param [Time] to_time
      #   The time to be compared against +from_time+ in order to approximate the distance.
      # @param [Boolean] include_seconds
      #   Set true for more detailed approximations.
      # @param [Hash] options
      #   Flags for the approximation.
      # @option options [String] :locale
      #   The translation locale to be used for approximating the time.
      #
      # @return [String] The time formatted as a relative string.
      #
      # @example
      #   from_time = Time.now
      #   distance_of_time_in_words(from_time, from_time + 50.minutes)        # => about 1 hour
      #   distance_of_time_in_words(from_time, 50.minutes.from_now)           # => about 1 hour
      #   distance_of_time_in_words(from_time, from_time + 15.seconds)        # => less than a minute
      #   distance_of_time_in_words(from_time, from_time + 15.seconds, true)  # => less than 20 seconds
      #   distance_of_time_in_words(from_time, 3.years.from_now)              # => about 3 years
      #   distance_of_time_in_words(from_time, from_time + 60.hours)          # => about 3 days
      #   distance_of_time_in_words(from_time, from_time + 45.seconds, true)  # => less than a minute
      #   distance_of_time_in_words(from_time, from_time - 45.seconds, true)  # => less than a minute
      #   distance_of_time_in_words(from_time, 76.seconds.from_now)           # => 1 minute
      #   distance_of_time_in_words(from_time, from_time + 1.year + 3.days)   # => about 1 year
      #   distance_of_time_in_words(from_time, from_time + 3.years + 6.months) # => over 3 years
      #   distance_of_time_in_words(from_time, from_time + 4.years + 9.days + 30.minutes + 5.seconds) # => about 4 years
      #   to_time = Time.now + 6.years + 19.days
      #   distance_of_time_in_words(from_time, to_time, true)     # => about 6 years
      #   distance_of_time_in_words(to_time, from_time, true)     # => about 6 years
      #   distance_of_time_in_words(Time.now, Time.now)           # => less than a minute
      #
      # @api public
      def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false, options = {})
        from_time = from_time.to_time if from_time.respond_to?(:to_time)
        to_time = to_time.to_time if to_time.respond_to?(:to_time)
        distance_in_minutes = (((to_time.to_i - from_time.to_i).abs)/60).round
        distance_in_seconds = ((to_time.to_i - from_time.to_i).abs).round

        I18n.with_options :locale => options[:locale], :scope => :'datetime.distance_in_words' do |locale|
          case distance_in_minutes
            when 0..1
              return distance_in_minutes == 0 ?
                     locale.t(:less_than_x_minutes, :count => 1) :
                     locale.t(:x_minutes, :count => distance_in_minutes) unless include_seconds

              case distance_in_seconds
                when 0..4   then locale.t :less_than_x_seconds, :count => 5
                when 5..9   then locale.t :less_than_x_seconds, :count => 10
                when 10..19 then locale.t :less_than_x_seconds, :count => 20
                when 20..39 then locale.t :half_a_minute
                when 40..59 then locale.t :less_than_x_minutes, :count => 1
                else             locale.t :x_minutes,           :count => 1
              end

            when 2..44           then locale.t :x_minutes,      :count => distance_in_minutes
            when 45..89          then locale.t :about_x_hours,  :count => 1
            when 90..1439        then locale.t :about_x_hours,  :count => (distance_in_minutes.to_f / 60.0).round
            when 1440..2529      then locale.t :x_days,         :count => 1
            when 2530..43199     then locale.t :x_days,         :count => (distance_in_minutes.to_f / 1440.0).round
            when 43200..86399    then locale.t :about_x_months, :count => 1
            when 86400..525599   then locale.t :x_months,       :count => (distance_in_minutes.to_f / 43200.0).round
            else
              distance_in_years           = distance_in_minutes / 525600
              minute_offset_for_leap_year = (distance_in_years / 4) * 1440
              remainder                   = ((distance_in_minutes - minute_offset_for_leap_year) % 525600)
              if remainder < 131400
                locale.t(:about_x_years,  :count => distance_in_years)
              elsif remainder < 394200
                locale.t(:over_x_years,   :count => distance_in_years)
              else
                locale.t(:almost_x_years, :count => distance_in_years + 1)
              end
          end
        end
      end

      ##
      # Like distance_of_time_in_words, but where <tt>to_time</tt> is fixed to <tt>Time.now</tt>.
      #
      # @param [Time] from_time
      #   The time to be compared against now in order to approximate the distance.
      # @param [Boolean] include_seconds
      #   Set true for more detailed approximations.
      #
      # @return [String] The time formatted as a relative string.
      #
      # @example
      #   time_ago_in_words(3.minutes.from_now)       # => 3 minutes
      #   time_ago_in_words(Time.now - 15.hours)      # => 15 hours
      #   time_ago_in_words(Time.now)                 # => less than a minute
      #
      # @api public
      def time_ago_in_words(from_time, include_seconds = false)
        distance_of_time_in_words(from_time, Time.now, include_seconds)
      end

      ##
      # Used in xxxx.js.erb files to escape html so that it can be passed to javascript from Padrino
      #
      # @param [String] html
      #   The html content to be escaped into javascript compatible format.
      #
      # @return [String] The html escaped for javascript passing.
      #
      # @example
      #   js_escape_html("<h1>Hey</h1>")
      #
      # @api public
      def js_escape_html(html_content)
        return '' unless html_content
        javascript_mapping = { '\\' => '\\\\', '</' => '<\/', "\r\n" => '\n', "\n" => '\n', "\r" => '\n', '"' => '\\"', "'" => "\\'" }
        html_content.gsub(/(\\|<\/|\r\n|[\n\r"'])/) { javascript_mapping[$1] }
      end
      alias :escape_javascript :js_escape_html
    end # FormatHelpers
  end # Helpers
end # Padrino
