class Middleman::Features::UglyHaml
  def initialize(app)
    Middleman::Base.set :haml, Middleman::Base.settings.haml.merge({ :ugly_haml => true })
  end
end

Middleman::Features.register :ugly_haml, Middleman::Features::UglyHaml