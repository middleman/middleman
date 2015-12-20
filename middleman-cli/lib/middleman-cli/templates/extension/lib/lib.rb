require "middleman-core"

Middleman::Extensions.register :<%= name %> do
  require "my-extension/extension"
  MyExtension
end
