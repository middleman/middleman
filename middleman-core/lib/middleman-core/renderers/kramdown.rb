require 'kramdown'

module Middleman
  module Renderers
    # Our own Kramdown Tilt template that simply uses our custom renderer.
    class KramdownTemplate < ::Tilt::KramdownTemplate
      private

      def _prepare_output
        @context = @options[:context]
        MiddlemanKramdownHTML.scope = @context || context

        @engine = Kramdown::Document.new(data, options)
        output, warnings = MiddlemanKramdownHTML.convert(@engine.root, @engine.options)
        @engine.warnings.concat(warnings)
        output
      end
    end

    # Custom Kramdown renderer that uses our helpers for images and links
    class MiddlemanKramdownHTML < ::Kramdown::Converter::Html
      cattr_accessor :scope

      def convert_img(el, _)
        attrs = el.attr.dup

        link = attrs.delete('src')
        scope.image_tag(link, attrs)
      end

      def convert_a(el, indent)
        content = inner(el, indent)

        if el.attr['href'].start_with?('mailto:')
          mail_addr = el.attr['href'].sub(/\Amailto:/, '')
          href = obfuscate('mailto') << ':' << obfuscate(mail_addr)
          content = obfuscate(content) if content == mail_addr
          return %(<a href="#{href}">#{content}</a>)
        end

        attr = el.attr.dup
        link = attr.delete('href')

        # options to link_to are expected to be symbols, but in Markdown
        # everything is a string.
        attr.transform_keys!(&:to_sym)

        scope.link_to(content, link, attr)
      end
    end
  end
end
