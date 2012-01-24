module Padrino
  module Helpers
    ##
    # Provides methods for converting numbers into formatted strings.
    # Methods are provided for phone numbers, currency, percentage,
    # precision, positional notation, and file size.
    #
    # Adapted from Rails Number Helpers.
    #
    module NumberHelpers
      ##
      # Formats a +number+ into a currency string (e.g., $13.65). You can customize the format
      # in the +options+ hash.
      #
      # @param [Float] number
      #   Currency value to format.
      # @param [Hash] options
      #   Options for currency conversion.
      # @option options [Fixnum] :precision (2)
      #   Sets the level of precision.
      # @option options [String] :unit ("$")
      #   Sets the denomination of the currency.
      # @option options [String] :separator (".")
      #   Sets the separator between the units.
      # @option options [String] :delimiter (",")
      #   Sets the thousands delimiter.
      # @option options [String] :format ("%u%n")
      #   Sets the format of the output string. The field types are:
      #     %u  The currency unit
      #     %n  The number
      #
      # @return [String] The formatted representation of the currency
      #
      # @example
      #   number_to_currency(1234567890.50)                    # => $1,234,567,890.50
      #   number_to_currency(1234567890.506)                   # => $1,234,567,890.51
      #   number_to_currency(1234567890.506, :precision => 3)  # => $1,234,567,890.506
      #   number_to_currency(1234567890.50, :unit => "&pound;", :separator => ",", :delimiter => "")
      #   # => &pound;1234567890,50
      #   number_to_currency(1234567890.50, :unit => "&pound;", :separator => ",", :delimiter => "", :format => "%n %u")
      #   # => 1234567890,50 &pound;
      #
      # @api public
      def number_to_currency(number, options = {})
        options.symbolize_keys!

        defaults  = I18n.translate(:'number.format', :locale => options[:locale], :raise => true) rescue {}
        currency  = I18n.translate(:'number.currency.format', :locale => options[:locale], :raise => true) rescue {}
        defaults  = defaults.merge(currency)

        precision = options[:precision] || defaults[:precision]
        unit      = options[:unit]      || defaults[:unit]
        separator = options[:separator] || defaults[:separator]
        delimiter = options[:delimiter] || defaults[:delimiter]
        format    = options[:format]    || defaults[:format]
        separator = '' if precision == 0

        begin
          format.gsub(/%n/, number_with_precision(number,
            :precision => precision,
            :delimiter => delimiter,
            :separator => separator)
          ).gsub(/%u/, unit)
        rescue
          number
        end
      end

      ##
      # Formats a +number+ as a percentage string (e.g., 65%). You can customize the
      # format in the +options+ hash.
      #
      # @param [Fixnum, Float] number
      #   Percentage value to format.
      # @param [Hash] options
      #   Options for percentage conversion.
      # @option options [Fixnum] :precision (3)
      #   Sets the level of precision.
      # @option options [String] :separator (".")
      #   Sets the separator between the units.
      # @option options [String] :delimiter ("")
      #   Sets the thousands delimiter
      #
      # @return [String] The formatted representation of the percentage
      #
      # @example
      #   number_to_percentage(100)                                        # => 100.000%
      #   number_to_percentage(100, :precision => 0)                       # => 100%
      #   number_to_percentage(1000, :delimiter => '.', :separator => ',') # => 1.000,000%
      #   number_to_percentage(302.24398923423, :precision => 5)           # => 302.24399%
      #
      # @api public
      def number_to_percentage(number, options = {})
        options.symbolize_keys!

        defaults   = I18n.translate(:'number.format', :locale => options[:locale], :raise => true) rescue {}
        percentage = I18n.translate(:'number.percentage.format', :locale => options[:locale], :raise => true) rescue {}
        defaults  = defaults.merge(percentage)

        precision = options[:precision] || defaults[:precision]
        separator = options[:separator] || defaults[:separator]
        delimiter = options[:delimiter] || defaults[:delimiter]

        begin
          number_with_precision(number,
            :precision => precision,
            :separator => separator,
            :delimiter => delimiter) + "%"
        rescue
          number
        end
      end

      ##
      # Formats a +number+ with grouped thousands using +delimiter+ (e.g., 12,324). You can
      # customize the format in the +options+ hash.
      #
      # @overload number_with_delimiter(number, options={})
      #   @param [Fixnum, Float] number
      #     Number value to format.
      #   @param [Hash] options
      #     Options for formatter.
      #   @option options [String] :delimiter (", ")
      #     Sets the thousands delimiter
      #   @option options [String] :separator (".")
      #     Sets the separator between the units.
      #
      # @return [String] The formatted representation of the number
      #
      # @example
      #   number_with_delimiter(12345678)                        # => 12,345,678
      #   number_with_delimiter(12345678.05)                     # => 12,345,678.05
      #   number_with_delimiter(12345678, :delimiter => ".")     # => 12.345.678
      #   number_with_delimiter(12345678, :separator => ",")     # => 12,345,678
      #   number_with_delimiter(98765432.98, :delimiter => " ", :separator => ",")
      #   # => 98 765 432,98
      #
      # @api public
      def number_with_delimiter(number, *args)
        options = args.extract_options!
        options.symbolize_keys!

        defaults = I18n.translate(:'number.format', :locale => options[:locale], :raise => true) rescue {}

        delimiter ||= (options[:delimiter] || defaults[:delimiter])
        separator ||= (options[:separator] || defaults[:separator])

        begin
          parts = number.to_s.split('.')
          parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
          parts.join(separator)
        rescue
          number
        end
      end

      ##
      # Formats a +number+ with the specified level of <tt>:precision</tt> (e.g., 112.32 has a precision of 2).
      # You can customize the format in the +options+ hash.
      #
      # @overload number_with_precision(number, options={})
      #   @param [Fixnum, Float] number
      #     Number value to format.
      #   @param [Hash] options
      #     Options for formatter.
      #   @option options [Fixnum] :precision (3)
      #     Sets the level of precision.
      #   @option options [String] :separator (".")
      #     Sets the separator between the units.
      #   @option options [String] :delimiter ("")
      #     Sets the thousands delimiter
      #
      # @return [String] The formatted representation of the number
      #
      # @example
      #   number_with_precision(111.2345)                    # => 111.235
      #   number_with_precision(111.2345, :precision => 2)   # => 111.23
      #   number_with_precision(13, :precision => 5)         # => 13.00000
      #   number_with_precision(389.32314, :precision => 0)  # => 389
      #   number_with_precision(1111.2345, :precision => 2, :separator => ',', :delimiter => '.')
      #   # => 1.111,23
      #
      # @api public
      def number_with_precision(number, *args)
        options = args.extract_options!
        options.symbolize_keys!

        defaults           = I18n.translate(:'number.format', :locale => options[:locale], :raise => true) rescue {}
        precision_defaults = I18n.translate(:'number.precision.format', :locale => options[:locale],
                                                                        :raise => true) rescue {}
        defaults           = defaults.merge(precision_defaults)

        precision ||= (options[:precision] || defaults[:precision])
        separator ||= (options[:separator] || defaults[:separator])
        delimiter ||= (options[:delimiter] || defaults[:delimiter])

        begin
          rounded_number = (Float(number) * (10 ** precision)).round.to_f / 10 ** precision
          number_with_delimiter("%01.#{precision}f" % rounded_number,
            :separator => separator,
            :delimiter => delimiter)
        rescue
          number
        end
      end

      # The units available for storage formatting.
      STORAGE_UNITS = [:byte, :kb, :mb, :gb, :tb].freeze

      ##
      # Formats the bytes in +size+ into a more understandable representation
      # (e.g., giving it 1500 yields 1.5 KB). This method is useful for
      # reporting file sizes to users. This method returns nil if
      # +size+ cannot be converted into a number. You can customize the
      # format in the +options+ hash.
      #
      #
      # @overload number_to_human_size(number, options={})
      #   @param [Fixnum] number
      #     Number value to format.
      #   @param [Hash] options
      #     Options for formatter.
      #   @option options [Fixnum] :precision (1)
      #     Sets the level of precision.
      #   @option options [String] :separator (".")
      #     Sets the separator between the units.
      #   @option options [String] :delimiter ("")
      #     Sets the thousands delimiter
      #
      # @return [String] The formatted representation of bytes
      #
      # @example
      #   number_to_human_size(123)                                          # => 123 Bytes
      #   number_to_human_size(1234)                                         # => 1.2 KB
      #   number_to_human_size(12345)                                        # => 12.1 KB
      #   number_to_human_size(1234567)                                      # => 1.2 MB
      #   number_to_human_size(1234567890)                                   # => 1.1 GB
      #   number_to_human_size(1234567890123)                                # => 1.1 TB
      #   number_to_human_size(1234567, :precision => 2)                     # => 1.18 MB
      #   number_to_human_size(483989, :precision => 0)                      # => 473 KB
      #   number_to_human_size(1234567, :precision => 2, :separator => ',')  # => 1,18 MB
      #
      # @api public
      def number_to_human_size(number, *args)
        return nil if number.nil?

        options = args.extract_options!
        options.symbolize_keys!

        defaults = I18n.translate(:'number.format', :locale => options[:locale], :raise => true) rescue {}
        human    = I18n.translate(:'number.human.format', :locale => options[:locale], :raise => true) rescue {}
        defaults = defaults.merge(human)

        precision ||= (options[:precision] || defaults[:precision])
        separator ||= (options[:separator] || defaults[:separator])
        delimiter ||= (options[:delimiter] || defaults[:delimiter])

        storage_units_format = I18n.translate(:'number.human.storage_units.format', :locale => options[:locale], :raise => true)

        if number.to_i < 1024
          unit = I18n.translate(:'number.human.storage_units.units.byte', :locale => options[:locale], :count => number.to_i, :raise => true)
          storage_units_format.gsub(/%n/, number.to_i.to_s).gsub(/%u/, unit)
        else
          max_exp  = STORAGE_UNITS.size - 1
          number   = Float(number)
          exponent = (Math.log(number) / Math.log(1024)).to_i # Convert to base 1024
          exponent = max_exp if exponent > max_exp # we need this to avoid overflow for the highest unit
          number  /= 1024 ** exponent

          unit_key = STORAGE_UNITS[exponent]
          unit = I18n.translate(:"number.human.storage_units.units.#{unit_key}", :locale => options[:locale], :count => number, :raise => true)

          begin
            escaped_separator = Regexp.escape(separator)
            formatted_number = number_with_precision(number,
              :precision => precision,
              :separator => separator,
              :delimiter => delimiter
            ).sub(/(#{escaped_separator})(\d*[1-9])?0+\z/, '\1\2').sub(/#{escaped_separator}\z/, '')
            storage_units_format.gsub(/%n/, formatted_number).gsub(/%u/, unit)
          rescue
            number
          end
        end
      end
    end # NumberHelpers
  end # Helpers
end # Padrino
