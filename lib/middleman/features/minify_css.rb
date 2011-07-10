module Middleman::Features::MinifyCss
  class << self
    def registered(app)
      app.after_compass_init do
        ::Compass.configuration.output_style = :compressed
      end
    end
    alias :included :registered
  end
end