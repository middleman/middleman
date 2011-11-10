require "tilt"

module Middleman::Renderers::ERb
  class << self
    def registered(app)
      app.extend ClassMethods
      
      app.set :erb_engine, :erb
      
      if !app.respond_to? :erb_engine_prefix
        app.set :erb_engine_prefix, ::Tilt
      end
      
      app.after_configuration do
        engine = app.settings.erb_engine
        
        if engine.is_a? Symbol
          engine = app.erb_tilt_template_from_symbol(engine)
        end
        
        ::Tilt.prefer(engine)
      end
    end
    alias :included :registered
  end
  
  module ClassMethods
    def erb_tilt_template_from_symbol(engine)
      engine = engine.to_s
      engine = engine == "erb" ? "ERB" : engine.camelize
      settings.erb_engine_prefix.const_get("#{engine}Template")
    end
  end
end