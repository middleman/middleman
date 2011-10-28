require "padrino-core/application/rendering"

module Middleman::CoreExtensions::Rendering
  class << self
    def registered(app)
      # Tilt-aware renderer
      app.register Padrino::Rendering

      # Activate custom renderers
      app.register Middleman::Renderers::Slim
      app.register Middleman::Renderers::Haml
      app.register Middleman::Renderers::Sass
      app.register Middleman::Renderers::Markdown
      app.register Middleman::Renderers::ERb
      app.register Middleman::Renderers::CoffeeScript
      app.register Middleman::Renderers::Liquid
    end
    alias :included :registered
  end
end