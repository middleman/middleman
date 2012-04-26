module Middleman
  module Renderers
    
    # CoffeeScript Renderer
    module CoffeeScript
      
      # Setup extension
      class << self
        # Once registered
        def registered(app)
          # Require gem
          require "coffee_script"
          
          app.before_configuration do
            template_extensions :coffee => :js
          end
        end
        alias :included :registered
      end
    end
  end
end