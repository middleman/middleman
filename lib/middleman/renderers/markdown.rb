module Middleman::Renderers::Markdown
  class << self
    def registered(app)
      app.send :include, InstanceMethods
      
      begin
        require "maruku"
        app.set :markdown_engine, :maruku
      rescue LoadError
        app.set :markdown_engine, nil
      end

      app.set :markdown_engine_prefix, ::Tilt
      
      app.after_configuration do
        unless markdown_engine.nil?
          if markdown_engine.is_a? Symbol
            markdown_engine = markdown_tilt_template_from_symbol(markdown_engine)
          end
        
          ::Tilt.prefer(markdown_engine)
        end
      end
    end
    alias :included :registered
  end
  
  module InstanceMethods
    def markdown_tilt_template_from_symbol(engine)
      engine = engine.to_s
      engine = engine == "rdiscount" ? "RDiscount" : engine.camelize
      markdown_engine_prefix.const_get("#{engine}Template")
    end
  end
end