# For URI templating
require 'addressable/uri'
require 'addressable/template'
require 'active_support/inflector'
require 'active_support/inflector/transliterate'

module Middleman
  module Util
    # Handy methods for dealing with URI templates. Mix into whatever class.
    module UriTemplates
      module_function

      # Given a URI template string, make an Addressable::Template
      # This supports the legacy middleman-blog/Sinatra style :colon
      # URI templates as well as RFC6570 templates.
      #
      # @param [String] tmpl_src URI template source
      # @return [Addressable::Template] a URI template
      def uri_template(tmpl_src)
        # Support the RFC6470 templates directly if people use them
        if tmpl_src.include?(':')
          tmpl_src = tmpl_src.gsub(/:([A-Za-z0-9]+)/, '{\1}')
        end

        ::Addressable::Template.new(::Middleman::Util.normalize_path(tmpl_src))
      end

      # Apply a URI template with the given data, producing a normalized
      # Middleman path.
      #
      # @param [Addressable::Template] template
      # @param [Hash] data
      # @return [String] normalized path
      def apply_uri_template(template, data)
        ::Middleman::Util.normalize_path(::Addressable::URI.unencode(template.expand(data)).to_s)
      end

      # Use a template to extract parameters from a path, and validate some special (date)
      # keys. Returns nil if the special keys don't match.
      #
      # @param [Addressable::Template] template
      # @param [String] path
      def extract_params(template, path)
        template.extract(path, BlogTemplateProcessor)
      end

      # Parameterize a string preserving any multibyte characters
      def safe_parameterize(str)
        sep = '-'

        # Reimplementation of http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-parameterize that preserves un-transliterate-able multibyte chars.
        parameterized_string = ::ActiveSupport::Inflector.transliterate(str.to_s).downcase
        parameterized_string.gsub!(/[^a-z0-9\-_\?]+/, sep)

        parameterized_string.chars.to_a.each_with_index do |char, i|
          next unless char == '?' && str[i].bytes.count != 1
          parameterized_string[i] = str[i]
        end

        re_sep = ::Regexp.escape(sep)
        # No more than one of the separator in a row.
        parameterized_string.gsub!(/#{re_sep}{2,}/, sep)
        # Remove leading/trailing separator.
        parameterized_string.gsub!(/^#{re_sep}|#{re_sep}$/, '')

        parameterized_string
      end

      # Convert a date into a hash of components to strings
      # suitable for using in a URL template.
      # @param [DateTime] date
      # @return [Hash] parameters
      def date_to_params(date)
        {
          year: date.year.to_s,
          month: date.month.to_s.rjust(2, '0'),
          day: date.day.to_s.rjust(2, '0')
        }
      end
    end

    # A special template processor that validates date fields
    # and has an extra-permissive default regex.
    #
    # See https://github.com/sporkmonger/addressable/blob/master/lib/addressable/template.rb#L279
    class BlogTemplateProcessor
      def self.match(name)
        case name
        when 'year' then '\d{4}'
        when 'month' then '\d{2}'
        when 'day' then '\d{2}'
        else '.*?'
        end
      end
    end
  end
end
