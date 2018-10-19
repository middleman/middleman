require "middleman-core"

Middleman::Extensions.register :<%= name %> do
  require "<%= name %>/extension"
  MyExtension
end
