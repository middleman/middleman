module Middleman::Renderers::Haml
  class << self
    def registered(app)
      require "haml"
      app.send :include, ::Haml::Helpers
      
      app.ready do
        init_haml_helpers
      end
    end
    alias :included :registered
  end
end