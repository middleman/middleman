module Middleman::Renderers::Haml
  class << self
    def registered(app)
      # Base library
      require "haml"

      # Coffee-script filter for Haml
      begin
        require "coffee-filter"
      rescue LoadError
      end
      
      # Code-ray Syntax highlighting
      begin
        require 'haml-coderay'
      rescue LoadError
      end
      
      app.helpers Helpers
      
      #app.set :haml, app.settings.haml.merge({ :ugly_haml => true })
    end
    alias :included :registered
  end
  
  module Helpers
    def haml_partial(name, options = {})
      render(name, options)
    end
  end
end