module Middleman
  module Renderers
    module Slim
      class << self
        def registered(app)
          require "slim"
        end
        alias :included :registered
      end
    end
  end
end