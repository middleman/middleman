module Middleman::Features::MinifyCss
  class << self
    def registered(app)
      require "middleman/features/minify_css/cssmin"
      app.before_configuration do
        set :css_compressor, ::CSSMin
      end
    end
    alias :included :registered
  end
end