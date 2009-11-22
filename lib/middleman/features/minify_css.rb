module Middleman
  module Minified
    module Sass
      include ::Haml::Filters::Base

      def render(text)
        result = ::Sass::Engine.new(text, ::Sass::Plugin.engine_options).render
        
        if Middleman::Base.respond_to?(:minify_css?) && Middleman::Base.minify_css?
          compressor = YUI::CssCompressor.new
          compressor.compress(result)
        else
          result
        end
      end
    end
  end
end