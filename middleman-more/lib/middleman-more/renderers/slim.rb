# Slim renderer
module Middleman::Renderers::Slim
  
  # Setup extension
  class << self
    
    # Once registered
    def registered(app)
      # Slim is not included in the default gems,
      # but we'll support it if available.
      begin
        # Load gem
        require "slim"
        
        # Setup Slim options to work with partials
        Slim::Engine.set_default_options(:buffer => '@_out_buf', :generator => Temple::Generators::StringBuffer) if defined?(Slim)
      rescue LoadError
      end
    end
    alias :included :registered
  end
end