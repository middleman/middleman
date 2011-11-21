module Middleman::Renderers::ERb
  class << self
    def registered(app)
      app.set :erb_engine, :erb
      app.set :erb_engine_prefix, ::Tilt
      
      app.after_configuration do
        if erb_engine.is_a? Symbol
          engine = engine.to_s
          engine = engine == "erb" ? "ERB" : engine.camelize
          erb_engine = erb_engine_prefix.const_get("#{engine}Template")
        end
        
        ::Tilt.prefer(erb_engine)
      end
    end
    alias :included :registered
  end
end