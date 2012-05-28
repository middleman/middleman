require "redcarpet"

module Middleman
  module Renderers

    class RedcarpetTemplate < ::Tilt::RedcarpetTemplate::Redcarpet2
      
      # Overwrite built-in Tilt version. 
      # Don't overload :renderer option with smartypants
      # Supper renderer-level options
      def generate_renderer
        return options.delete(:renderer) if options.has_key?(:renderer)
        
        # Pick a renderer
        renderer = ::Redcarpet::Render::HTML
        
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
   
    ::Tilt.register RedcarpetTemplate, 'markdown', 'mkd', 'md'
  end
end