module Middleman::Features::MinifyCss
  class << self
    def registered(app)
      app.compass_config do |config|
        config.output_style = :compressed
      end
    end
    alias :included :registered
  end
end