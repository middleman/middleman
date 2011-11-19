module Padrino
  module Helpers
    ##
    # Helpers related to producing html tags within templates.
    #
    module TagHelpers
      ##
      # Tag values escaped to html entities
      #
      ESCAPE_VALUES = {
        "<" => "&lt;",
        ">" => "&gt;",
        '"' => "&quot;"
      }

      ##
      # Creates an html tag with given name, content and options
      #
      # @overload content_tag(name, content, options)
      #   @param [Symbol]  name     The html type of tag.
      #   @param [String]  content  The contents in the tag.
      #   @param [Hash]    options  The html options to include in this tag.
      # @overload content_tag(name, options, &block)
      #   @param [Symbol]  name     The html type of tag.
      #   @param [Hash]    options  The html options to include in this tag.
      #   @param [Proc]    block    The block returning html content
      #
      # @return [String] The html generated for the tag.
      #
      # @example
      #   content_tag(:p, "hello", :class => 'light')
      #   content_tag(:p, :class => 'dark') { ... }
      #
      # @api public
      def content_tag(*args, &block)
        name = args.first
        options = args.extract_options!
        tag_html = block_given? ? capture_html(&block) : args[1]
        tag_result = tag(name, options.merge(:content => tag_html))
        block_is_template?(block) ? concat_content(tag_result) : tag_result
      end

      ##
      # Creates an html input field with given type and options
      #
      # @param [Symbol] type
      #   The html type of tag to create.
      # @param [Hash] options
      #   The html options to include in this tag.
      #
      # @return [String] The html for the input tag.
      #
      # @example
      #   input_tag :text, :class => "test"
      #   input_tag :password, :size => "20"
      #
      # @api semipublic
      def input_tag(type, options = {})
        options.reverse_merge!(:type => type)
        tag(:input, options)
      end

      ##
      # Creates an html tag with the given name and options
      #
      # @param [Symbol] type
      #   The html type of tag to create.
      # @param [Hash] options
      #   The html options to include in this tag.
      #
      # @return [String] The html for the input tag.
      #
      # @example
      #   tag(:br, :style => 'clear:both')
      #   tag(:p, :content => "hello", :class => 'large')
      #
      # @api public
      def tag(name, options={})
        content, open_tag = options.delete(:content), options.delete(:open)
        content = content.join("\n") if content.respond_to?(:join)
        identity_tag_attributes.each { |attr| options[attr] = attr.to_s if options[attr]  }
        html_attrs = options.map { |a, v| v.nil? || v == false ? nil : "#{a}=\"#{escape_value(v)}\"" }.compact.join(" ")
        base_tag = (html_attrs.present? ? "<#{name} #{html_attrs}" : "<#{name}")
        base_tag << (open_tag ? ">" : (content ? ">#{content}</#{name}>" : " />"))
      end

      private
        ##
        # Returns a list of attributes which can only contain an identity value (i.e selected)
        #
        def identity_tag_attributes
          [:checked, :disabled, :selected, :multiple]
        end

        ##
        # Escape tag values to their HTML/XML entities.
        #
        def escape_value(string)
          string.to_s.gsub(Regexp.union(*ESCAPE_VALUES.keys)){|c| ESCAPE_VALUES[c] }
        end
    end # TagHelpers
  end # Helpers
end # Padrino
