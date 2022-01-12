# frozen_string_literal: true

require 'middleman-core/template_context'

# ERb Support
Middleman::Extensions.register :erb_renderer, auto_activate: :before_configuration do
  require 'middleman-core/renderers/erb'
  Middleman::Renderers::ERb
end

# Haml Support
Middleman::Extensions.register :haml_renderer, auto_activate: :before_configuration do
  require 'middleman-core/renderers/haml'
  Middleman::Renderers::Haml
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
