module Middleman::Extensions
  module MinifyCss
    class << self
      def registered(app)
        app.after_configuration do
          if !css_compressor
            require "middleman/extensions/minify_css/cssmin"
            set :css_compressor, ::CSSMin
          end
        end
      end
      alias :included :registered
    end
  end
  
  register :minify_css, MinifyCss
end