class LayoutDisabler < Middleman::Extension
  def initialize(app, options_hash = {}, &block)
    super

    app.set :layout, false
  end
end

::Middleman::Extensions.register(:layout_disabler, LayoutDisabler)

activate :layout_disabler
