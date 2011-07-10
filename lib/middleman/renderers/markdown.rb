module Middleman::Renderers::Markdown
  class << self
    def registered(app)
      app.set :markdown, ::Tilt::RDiscountTemplate
      app.after_feature_init do
        ::Tilt.prefer(app.settings.markdown)
      end
    end
    alias :included :registered
  end
end