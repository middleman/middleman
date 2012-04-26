### 
# Setup renderers
###

# CoffeeScript Support
require "middleman-more/renderers/coffee_script"
Middleman::Application.register Middleman::Renderers::CoffeeScript

# Haml Support
require "middleman-more/renderers/haml"
Middleman::Application.register Middleman::Renderers::Haml

# Sass Support
require "middleman-more/renderers/sass"
Middleman::Application.register Middleman::Renderers::Sass

# Markdown Support
require "middleman-more/renderers/markdown"
Middleman::Application.register Middleman::Renderers::Markdown

# Liquid Support
require "middleman-more/renderers/liquid"
Middleman::Application.register Middleman::Renderers::Liquid

# Slim Support
require "middleman-more/renderers/slim"
Middleman::Application.register Middleman::Renderers::Slim

### 
# Setup Core Extensions
###

# Compass framework
require "middleman-more/core_extensions/compass"
Middleman::Application.register Middleman::CoreExtensions::Compass

# Sprockets asset handling
require "middleman-more/core_extensions/sprockets"
Middleman::Application.register Middleman::CoreExtensions::Sprockets

### 
# Setup Optional Extensions
###

# CacheBuster adds a query string to assets in dynamic templates to avoid
# browser caches failing to update to your new content.
Middleman::Extensions.register(:cache_buster) do
  require "middleman-more/extensions/cache_buster"
  Middleman::Extensions::CacheBuster 
end

# MinifyCss compresses CSS
Middleman::Extensions.register(:minify_css) do
  require "middleman-more/extensions/minify_css"
  Middleman::Extensions::MinifyCss 
end

# MinifyJavascript compresses JS
Middleman::Extensions.register(:minify_javascript) do
  require "middleman-more/extensions/minify_javascript"
  Middleman::Extensions::MinifyJavascript 
end
  
# RelativeAssets allow any asset path in dynamic templates to be either
# relative to the root of the project or use an absolute URL.
Middleman::Extensions.register(:relative_assets) do
  require "middleman-more/extensions/relative_assets"
  Middleman::Extensions::RelativeAssets 
end

# GZIP assets and pages during build
Middleman::Extensions.register(:gzip) do
  require "middleman-more/extensions/gzip"
  Middleman::Extensions::Gzip 
end
  
# AssetHash appends a hash of the file contents to the assets filename
# to avoid browser caches failing to update to your new content.
Middleman::Extensions.register(:asset_hash) do
  require "middleman-more/extensions/asset_hash"
  Middleman::Extensions::AssetHash 
end