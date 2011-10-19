module Middleman::Features::MinifyCss
  class << self
    def registered(app)
      require "middleman/features/minify_css/cssmin"
      app.set :css_compressor, ::CSSMin
    end
    alias :included :registered
  end
end