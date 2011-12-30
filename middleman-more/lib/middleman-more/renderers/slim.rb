module Middleman::Renderers::Slim
  class << self
    def registered(app)
      # Slim is not included in the default gems,
      # but we'll support it if available.
      begin
        require "slim"
        
        Slim::Engine.set_default_options(:buffer => '@_out_buf', :generator => Temple::Generators::StringBuffer) if defined?(Slim)
      rescue LoadError
      end
    end
    alias :included :registered
  end
end