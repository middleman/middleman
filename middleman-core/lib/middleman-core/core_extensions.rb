# Rack Request
require 'middleman-core/core_extensions/request'

# File Change Notifier
require 'middleman-core/core_extensions/file_watcher'

# Custom Feature API
require 'middleman-core/core_extensions/extensions'

# Data looks at the data/ folder for YAML files and makes them available
# to dynamic requests.
require 'middleman-core/core_extensions/data'

# Parse YAML from templates
Middleman::Extensions.register :front_matter do
  require 'middleman-core/core_extensions/front_matter'
  Middleman::CoreExtensions::FrontMatter
end

# External helpers looks in the helpers/ folder for helper modules
require 'middleman-core/core_extensions/external_helpers'

# Extended version of Padrino's rendering
require 'middleman-core/core_extensions/rendering'

# Pass custom options to views
require 'middleman-core/core_extensions/routing'

# Catch and show exceptions at the Rack level
require 'middleman-core/core_extensions/show_exceptions'

# Setup default helpers
Middleman::Extensions.register :default_helpers do
  require 'middleman-core/core_extensions/default_helpers'
  Middleman::CoreExtensions::DefaultHelpers
end

# Compass framework
Middleman::Extensions.register :compass do
  require 'middleman-core/core_extensions/compass'
  Middleman::CoreExtensions::Compass
end

###
# Setup Optional Extensions
###

Middleman::Extensions.register :i18n_v3 do
  require 'middleman-core/core_extensions/i18n_v3'
  Middleman::CoreExtensions::InternationalizationV3
end

Middleman::Extensions.register :i18n do
  require 'middleman-core/core_extensions/i18n_v4'
  Middleman::CoreExtensions::Internationalization
end

# CacheBuster adds a query string to assets in dynamic templates to
# avoid browser caches failing to update to your new content.
Middleman::Extensions.register :cache_buster do
  require 'middleman-core/extensions/cache_buster'
  Middleman::Extensions::CacheBuster
end

# RelativeAssets allow any asset path in dynamic templates to be either
# relative to the root of the project or use an absolute URL.
Middleman::Extensions.register :relative_assets do
  require 'middleman-core/extensions/relative_assets'
  Middleman::Extensions::RelativeAssets
end

# AssetHost allows you to setup multiple domains to host your static
# assets. Calls to asset paths in dynamic templates will then rotate
# through each of the asset servers to better spread the load.
Middleman::Extensions.register :asset_host do
  require 'middleman-core/extensions/asset_host'
  Middleman::Extensions::AssetHost
end

# MinifyCss compresses CSS
Middleman::Extensions.register :minify_css do
  require 'middleman-core/extensions/minify_css'
  Middleman::Extensions::MinifyCss
end

# MinifyJavascript compresses JS
Middleman::Extensions.register :minify_javascript do
  require 'middleman-core/extensions/minify_javascript'
  Middleman::Extensions::MinifyJavascript
end

# GZIP assets and pages during build
Middleman::Extensions.register :gzip do
  require 'middleman-core/extensions/gzip'
  Middleman::Extensions::Gzip
end

# AssetHash appends a hash of the file contents to the assets filename
# to avoid browser caches failing to update to your new content.
Middleman::Extensions.register :asset_hash do
  require 'middleman-core/extensions/asset_hash'
  Middleman::Extensions::AssetHash
end

# Provide Apache-style index.html files for directories
Middleman::Extensions.register :directory_indexes do
  require 'middleman-core/extensions/directory_indexes'
  Middleman::Extensions::DirectoryIndexes
end

# Lorem provides a handful of helpful prototyping methods to generate
# words, paragraphs, fake images, names and email addresses.
Middleman::Extensions.register :lorem do
  require 'middleman-core/extensions/lorem'
  Middleman::Extensions::Lorem
end

# AutomaticImageSizes inspects the images used in your dynamic templates
# and automatically adds width and height attributes to their HTML
# elements.
Middleman::Extensions.register :automatic_image_sizes do
  require 'middleman-core/extensions/automatic_image_sizes'
  Middleman::Extensions::AutomaticImageSizes
end

# AutomaticAltTags uses the file name of the `image_tag` to generate
# a default `:alt` value.
Middleman::Extensions.register :automatic_alt_tags do
  require 'middleman-core/extensions/automatic_alt_tags'
  Middleman::Extensions::AutomaticAltTags
end
