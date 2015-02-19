require 'kramdown'

module Middleman
  module Renderers
    # Our own Kramdown Tilt template that simply uses our custom renderer.
    class KramdownTemplate < ::Tilt::KramdownTemplate
      def evaluate(*)
        @output ||= begin
          output, warnings = MiddlemanKramdownHTML.convert(@engine.root, @engine.options)
          @engine.warnings.concat(warnings)
          output
        end
      end
    end

    # Custom Kramdown renderer that uses our helpers for images and links
    class MiddlemanKramdownHTML < ::Kramdown::Converter::Html
      cattr_accessor :middleman_app

      def convert_img(el, _)
        attrs = el.attr.dup

        link = attrs.delete('src')
        middleman_app.image_tag(link, attrs)
      end

      def convert_a(el, indent)
        content = inner(el, indent)

        if el.attr['href'] =~ /\Amailto:/
          mail_addr = el.attr['href'].sub(/\Amailto:/, '')
          href = obfuscate('mailto') << ':' << obfuscate(mail_addr)
          content = obfuscate(content) if content == mail_addr
          return %(<a href="#{href}">#{content}</a>)
        end

        attr = el.attr.dup
        link = attr.delete('href')
        middleman_app.link_to(content, link, attr)
      end
    end
  end
end
