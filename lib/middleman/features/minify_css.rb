class Middleman::Base
  after_feature_init do
    ::Compass.configuration do |config|
      config.output_style = :compressed
    end

    ::Compass.configure_sass_plugin!
  end
end