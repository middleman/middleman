# Require gem
require "haml"
  
# Haml Renderer
module Middleman::Renderers::Haml
  
  # Setup extension
  class << self
    # Once registered
    def registered(app)
      # Add haml helpers to context
      app.send :include, ::Haml::Helpers
      
      # Setup haml helper paths
      app.ready do
        init_haml_helpers
      end
    end
    alias :included :registered
  end
end