module Middleman::Renderers::Haml
  class << self
    def registered(app)
      # Base library
      require "haml"

      # Coffee-script filter for Haml
      require "coffee-filter"
      
      app.helpers Helpers
    end
    alias :included :registered
  end
  
  module Helpers
    def haml_partial(name, options = {})
      render(name, options)
    end
  end
end