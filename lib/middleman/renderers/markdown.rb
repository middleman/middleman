module Middleman::Renderers::Markdown
  class << self
    def registered(app)
      app.set :markdown_engine, ::Tilt::MarukuTemplate
      app.after_configuration do
        ::Tilt.prefer(app.settings.markdown_engine)
      end
    end
    alias :included :registered
  end
end