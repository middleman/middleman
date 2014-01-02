require 'kramdown'

module Middleman
  module Renderers

    # Our own Kramdown Tilt template that simply uses our custom renderer.
    class KramdownTemplate < ::Tilt::KramdownTemplate
      def evaluate(scope, locals, &block)
        @output ||= begin
          MiddlemanKramdownHTML.scope = ::Middleman::Renderers::Haml.last_haml_scope || scope

          output, warnings = MiddlemanKramdownHTML.convert(@engine.root, @engine.options)
          @engine.warnings.concat(warnings)
          output
        end
      end
    end

    # Custom Kramdown renderer that uses our helpers for images and links
    class MiddlemanKramdownHTML < ::Kramdown::Converter::Html
      cattr_accessor :scope

      def convert_img(el, indent)
        attrs = el.attr.dup

        link = attrs.delete('src')
        scope.image_tag(link, attrs)
      end

      def convert_a(el, indent)
        content = inner(el, indent)

        if el.attr['href'] =~ /\Amailto:/
          mail_addr = el.attr['href'].sub(/\Amailto:/, '')
          href = obfuscate('mailto') << ':' << obfuscate(mail_addr)
          content = obfuscate(content) if content == mail_addr
          return %Q{<a href="#{href}">#{content}</a>}
        end

        attr = el.attr.dup
        link = attr.delete('href')
        scope.link_to(content, link, attr)
      end
    end
  end
end
