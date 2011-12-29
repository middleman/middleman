module Middleman::Renderers::Markdown
  class << self
    def registered(app)
      require "redcarpet"
      
      # Forcably disable Redcarpet1 support.
      # Tilt defaults to this if available, but the compat
      # layer disables extensions.
      Object.send(:remove_const, :RedcarpetCompat) if defined? ::RedcarpetCompat
      
      app.set :markdown_engine, :redcarpet
      app.set :markdown_engine_prefix, ::Tilt
      
      app.after_configuration do
        unless markdown_engine.nil?
          if markdown_engine.is_a? Symbol
            engine = engine.to_s
            engine = engine == "rdiscount" ? "RDiscount" : engine.camelize
            markdown_engine = markdown_engine_prefix.const_get("#{engine}Template")
          end
        
          ::Tilt.prefer(markdown_engine)
        end
      end
    end
    alias :included :registered
  end
end