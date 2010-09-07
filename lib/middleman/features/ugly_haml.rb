module Middleman::Features::UglyHaml
  class << self
    def registered(app)
      app.set :haml, app.settings.haml.merge({ :ugly_haml => true })
    end
    alias :included :registered
  end
end