module Middleman::Extensions
  module MinifyCss
    class << self
      def registered(app)
        require "middleman/extensions/minify_css/cssmin"
        app.after_configuration do
          set :css_compressor, ::CSSMin
        end
      end
      alias :included :registered
    end
  end
  
  register :minify_css, MinifyCss
end