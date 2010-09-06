class Middleman::Features::MinifyCSS
  def initialize(app, config)
    Middleman::Server.after_feature_init do
      ::Compass.configuration.output_style = :compressed
    end
  end
end

Middleman::Features.register :minify_css, Middleman::Features::MinifyCSS