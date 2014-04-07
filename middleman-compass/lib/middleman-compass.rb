require "middleman-core"

Middleman::Extensions.register(:compass) do
  require "middleman-compass/extension"
  Middleman::CompassExtension
end
