require 'middleman-core/template_context'

# ERb Support
Middleman::Extensions.register :erb_renderer, auto_activate: :before_configuration do
  require 'middleman-core/renderers/erb'
  Middleman::Renderers::ERb
end

# CoffeeScript Support
Middleman::Extensions.register :coffee_renderer, auto_activate: :before_configuration do
  require 'middleman-core/renderers/coffee_script'
  Middleman::Renderers::CoffeeScript
end

# Haml Support
Middleman::Extensions.register :haml_renderer, auto_activate: :before_configuration do
  require 'middleman-core/renderers/haml'
  Middleman::Renderers::Haml
end

# Sass Support
Middleman::Extensions.register :sass_renderer, auto_activate: :before_configuration do
  require 'middleman-core/renderers/sass'
  Middleman::Renderers::Sass
end

# Markdown Support
Middleman::Extensions.register :markdown_renderer, auto_activate: :before_configuration do
  require 'middleman-core/renderers/markdown'
  Middleman::Renderers::Markdown
end

# Liquid Support
Middleman::Extensions.register :liquid_renderer, auto_activate: :before_configuration do
  require 'middleman-core/renderers/liquid'
  Middleman::Renderers::Liquid
end

# Slim Support
Middleman::Extensions.register :slim_renderer, auto_activate: :before_configuration do
  require 'middleman-core/renderers/slim'
  Middleman::Renderers::Slim
end

# Less Support
Middleman::Extensions.register :less_renderer, auto_activate: :before_configuration do
  require 'middleman-core/renderers/less'
  Middleman::Renderers::Less
end

# Stylus Support
Middleman::Extensions.register :stylus_renderer, auto_activate: :before_configuration do
  require 'middleman-core/renderers/stylus'
  Middleman::Renderers::Stylus
end
