module Middleman::CoreExtensions::Rendering
  class << self
    def registered(app)
      # Activate custom renderers
      app.register Middleman::Renderers::Sass
      app.register Middleman::Renderers::Markdown
      app.register Middleman::Renderers::ERb
      app.register Middleman::Renderers::Liquid
    end
    alias :included :registered
  end
end