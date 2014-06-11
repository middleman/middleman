require "middleman-core"

Middleman::Extensions.register :compass, auto_activate: :before_configuration do
  require "middleman-compass/extension"
  Middleman::CompassExtension
end
