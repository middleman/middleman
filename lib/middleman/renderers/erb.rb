require "tilt"

module Middleman::Renderers::ERb
  class << self
    def registered(app)
      app.send :include, InstanceMethods
      
      app.set :erb_engine, :erb
      app.set :erb_engine_prefix, ::Tilt
      
      app.after_configuration do
        if erb_engine.is_a? Symbol
          erb_engine = erb_tilt_template_from_symbol(erb_engine)
        end
        
        ::Tilt.prefer(erb_engine)
      end
    end
    alias :included :registered
  end
  
  module InstanceMethods
    def erb_tilt_template_from_symbol(engine)
      engine = engine.to_s
      engine = engine == "erb" ? "ERB" : engine.camelize
      erb_engine_prefix.const_get("#{engine}Template")
    end
  end
end