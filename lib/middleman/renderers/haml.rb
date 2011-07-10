require "haml"
require "coffee-filter"

module Middleman
  module Renderers
    module Haml
      class << self
        def registered(app)
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
  end
end