module Middleman
  module Renderers
    
    # Slim renderer
    module Slim
  
      # Setup extension
      class << self
    
        # Once registered
        def registered(app)
          # Slim is not included in the default gems,
          # but we'll support it if available.
          begin
            # Load gem
            require "slim"
        
            app.before_configuration do
              template_extensions :slim => :html
            end
        
            # Setup Slim options to work with partials
            ::Slim::Engine.set_default_options(
              :buffer    => '@_out_buf', 
              :generator => ::Temple::Generators::StringBuffer
            )
          rescue LoadError
          end
        end
    
        alias :included :registered
      end
    end
  end
end