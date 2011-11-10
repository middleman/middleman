module Middleman::Renderers::Markdown
  class << self
    def registered(app)
      app.extend ClassMethods
      
      app.set :markdown_engine, nil
      
      if !app.respond_to? :markdown_engine_prefix
        app.set :markdown_engine_prefix, ::Tilt
      end
      
      app.after_configuration do
        engine = app.settings.markdown_engine
        
        unless engine.nil?
          if engine.is_a? Symbol
            engine = app.markdown_tilt_template_from_symbol(engine)
          end
        
          ::Tilt.prefer(engine)
        end
      end
    end
    alias :included :registered
  end
  
  module ClassMethods
    def markdown_tilt_template_from_symbol(engine)
      engine = engine.to_s
      engine = engine == "rdiscount" ? "RDiscount" : engine.camelize
      settings.markdown_engine_prefix.const_get("#{engine}Template")
    end
  end
end