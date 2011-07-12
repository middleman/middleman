module Middleman::Renderers::Markdown
  class << self
    def registered(app)
      app.set :markdown_engine, ::Tilt::RDiscountTemplate
      app.after_feature_init do
        ::Tilt.prefer(app.settings.markdown_engine)
      end
    end
    alias :included :registered
  end
end