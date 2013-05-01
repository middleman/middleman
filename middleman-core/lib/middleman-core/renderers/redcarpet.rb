require "redcarpet"

module Middleman
  module Renderers

    class RedcarpetTemplate < ::Tilt::RedcarpetTemplate::Redcarpet2
      # Overwrite built-in Tilt version.
      # Don't overload :renderer option with smartypants
      # Support renderer-level options
      def generate_renderer
        return options.delete(:renderer) if options.has_key?(:renderer)

        # Pick a renderer
        renderer = MiddlemanRedcarpetHTML

        # Support SmartyPants
        if options.delete(:smartypants)
          renderer = Class.new(renderer) do
            include ::Redcarpet::Render::SmartyPants
          end
        end

        # Renderer Options
        possible_render_opts = [:filter_html, :no_images, :no_links, :no_styles, :safe_links_only, :with_toc_data, :hard_wrap, :xhtml]

        render_options = possible_render_opts.inject({}) do |sum, opt|
          sum[opt] = options.delete(opt) if options.has_key?(opt)
          sum
        end

        renderer.new(render_options)
      end
    end

    # Custom Redcarpet renderer that uses our helpers for images and links
    class MiddlemanRedcarpetHTML < ::Redcarpet::Render::HTML
      cattr_accessor :middleman_app

      def image(link, title, alt_text)
        if middleman_app && middleman_app.context.respond_to?(:image_tag)
          middleman_app.context.image_tag(link, :title => title, :alt => alt_text)
        else
          img = "<img src=\"#{link}\""
          img << " title=\"#{title}\"" if title
          img << " alt=\"#{alt_text}\"" if alt_text
          img << ">"
        end
      end

      def link(link, title, content)
        if middleman_app && middleman_app.context.respond_to?(:link_to)
          middleman_app.context.link_to(content, link, :title => title)
        else
          a = "<a href=\"#{link}\""
          a << " title=\"#{title}\"" if title
          a << ">#{content}</a>"
        end
      end
    end

    ::Tilt.register RedcarpetTemplate, 'markdown', 'mkd', 'md'
  end
end
