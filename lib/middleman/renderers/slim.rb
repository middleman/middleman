module Middleman::Renderers::Slim
  class << self
    def registered(app)
      require "slim"
    end
    alias :included :registered
  end
end