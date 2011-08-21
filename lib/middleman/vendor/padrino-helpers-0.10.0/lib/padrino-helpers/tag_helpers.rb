module Padrino
  module Helpers
    module TagHelpers
      ##
      # Creates an html input field with given type and options
      #
      # ==== Examples
      #
      #   input_tag :text, :class => "test"
      #
      def input_tag(type, options = {})
        options.reverse_merge!(:type => type)
        tag(:input, options)
      end

      ##
      # Creates an html tag with given name, content and options
      #
      # ==== Examples
      #
      #   content_tag(:p, "hello", :class => 'light')
      #   content_tag(:p, :class => 'dark') do ... end
      #   content_tag(name, content=nil, options={}, &block)
      #
      def content_tag(*args, &block)
        name = args.first
        options = args.extract_options!
        tag_html = block_given? ? capture_html(&block) : args[1]
        tag_result = tag(name, options.merge(:content => tag_html))
        block_is_template?(block) ? concat_content(tag_result) : tag_result
      end

      ##
      # Creates an html tag with the given name and options
      #
      # ==== Examples
      #
      #   tag(:br, :style => 'clear:both')
      #   tag(:p, :content => "hello", :class => 'large')
      #
      def tag(name, options={})
        content, open_tag = options.delete(:content), options.delete(:open)
        content = content.join("\n") if content.respond_to?(:join)
        identity_tag_attributes.each { |attr| options[attr] = attr.to_s if options[attr]  }
        html_attrs = options.map { |a, v| v.nil? || v == false ? nil : "#{a}=\"#{v}\"" }.compact.join(" ")
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
    end # TagHelpers
  end # Helpers
end # Padrino