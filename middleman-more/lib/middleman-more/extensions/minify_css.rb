# Extensions namespace
module Middleman::Extensions
  
  # Minify CSS Extension 
  module MinifyCss
    
    # Setup extension
    class << self
      
      # Once registered
      def registered(app)
        # Tell Sprockets to use the built in CSSMin
        app.after_configuration do
          if !css_compressor
            require "middleman-more/extensions/minify_css/rainpress"
            set :css_compressor, ::Rainpress
          end
        end
      end
      alias :included :registered
    end
  end
  
  # Register extension
  # register :minify_css, MinifyCss
end