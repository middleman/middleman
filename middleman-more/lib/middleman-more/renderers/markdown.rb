# Markdown renderer
module Middleman::Renderers::Markdown
  
  # Setup extension
  class << self
    
    # Once registered
    def registered(app)
      # Require redcarpet gem
      require "redcarpet"
      
      # Forcably disable Redcarpet1 support.
      # Tilt defaults to this if available, but the compat
      # layer disables extensions.
      Object.send(:remove_const, :RedcarpetCompat) if defined? ::RedcarpetCompat
      
      # Set our preference for a markdown engine
      app.set :markdown_engine, :redcarpet
      app.set :markdown_engine_prefix, ::Tilt
      
      # Once configuration is parsed
      app.after_configuration do
        
        # Look for the user's preferred engine
        unless markdown_engine.nil?
          
          # Map symbols to classes
          if markdown_engine.is_a? Symbol
            engine = markdown_engine.to_s
            engine = engine == "rdiscount" ? "RDiscount" : engine.camelize
            markdown_engine = markdown_engine_prefix.const_get("#{engine}Template")
          end
        
          # Tell tilt to use that engine
          ::Tilt.prefer(markdown_engine)
        end
      end
    end
    
    alias :included :registered
  end
end