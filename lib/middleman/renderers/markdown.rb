module Middleman::Renderers::Markdown
  class << self
    def registered(app)
      app.set :markdown_engine, nil
    
      begin
        require "maruku"
        app.set :markdown_engine, :maruku
      rescue LoadError
        begin
          require "rdiscount"
          app.set :markdown_engine, :rdiscount
        rescue LoadError
        end
      end

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