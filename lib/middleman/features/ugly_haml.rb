class Middleman::Features::UglyHaml
  def initialize(app, config)
    Middleman::Server.set :haml, Middleman::Server.settings.haml.merge({ :ugly_haml => true })
  end
end

Middleman::Features.register :ugly_haml, Middleman::Features::UglyHaml