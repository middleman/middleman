module Middleman
  module Renderers
    module Markdown
      class << self
        def registered(app)
          require "rdiscount"
        end
        alias :included :registered
      end
    end
  end
end