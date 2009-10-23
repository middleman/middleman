# Otherwise use YUI
# Fine a way to minify inline/css
class Middleman::Base
  configure do
    ::Compass.configuration do |config|
      config.output_style = :compressed
    end
  end
end