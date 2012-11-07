require "redcarpet"

module Middleman
  module Renderers

    class RedcarpetTemplate < ::Tilt::RedcarpetTemplate::Redcarpet2

      def initialize(*args, &block)
        super
        
        if @options.has_key?(:context)
          @context = @options[:context]
        end
      end

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

      def evaluate(context, locals, &block)
        @context ||= context

        if @engine.renderer.respond_to? :middleman_app=
          @engine.renderer.middleman_app = @context
        end
        super
      end
    end

    # Custom Redcarpet renderer that uses our helpers for images and links
    class MiddlemanRedcarpetHTML < ::Redcarpet::Render::HTML
      attr_accessor :middleman_app

      def image(link, title, alt_text)
        middleman_app.image_tag(link, :title => title, :alt => alt_text)
      end

      def link(link, title, content)
        middleman_app.link_to(content, link, :title => title)
      end
    end

    ::Tilt.register RedcarpetTemplate, 'markdown', 'mkd', 'md'
  end
end
