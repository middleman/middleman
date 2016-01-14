require 'middleman-core/extensions'

# File Change Notifier
Middleman::Extensions.register :file_watcher, auto_activate: :before_sitemap do
  require 'middleman-core/core_extensions/file_watcher'
  Middleman::CoreExtensions::FileWatcher
end

# Parse YAML from templates
Middleman::Extensions.register :front_matter, auto_activate: :before_sitemap do
  require 'middleman-core/core_extensions/front_matter'
  Middleman::CoreExtensions::FrontMatter
end

# Data looks at the data/ folder for YAML files and makes them available
# to dynamic requests.
Middleman::Extensions.register :data, auto_activate: :before_sitemap do
  require 'middleman-core/core_extensions/data'
  Middleman::CoreExtensions::Data
end

# Rewrite embedded URLs via Rack
Middleman::Extensions.register :inline_url_rewriter, auto_activate: :before_sitemap do
  require 'middleman-core/core_extensions/inline_url_rewriter'
  Middleman::CoreExtensions::InlineURLRewriter
end

# Catch and show exceptions at the Rack level
Middleman::Extensions.register :show_exceptions, auto_activate: :before_configuration, modes: [:server] do
  require 'middleman-core/core_extensions/show_exceptions'
  Middleman::CoreExtensions::ShowExceptions
end

# External helpers looks in the helpers/ folder for helper modules
Middleman::Extensions.register :external_helpers, auto_activate: :before_configuration do
  require 'middleman-core/core_extensions/external_helpers'
  Middleman::CoreExtensions::ExternalHelpers
end

# Extended version of Padrino's rendering
require 'middleman-core/core_extensions/rendering'

# Setup default helpers
Middleman::Extensions.register :default_helpers, auto_activate: :before_configuration do
  require 'middleman-core/core_extensions/default_helpers'
  Middleman::CoreExtensions::DefaultHelpers
end

# Lorem provides a handful of helpful prototyping methods to generate
# words, paragraphs, fake images, names and email addresses.
Middleman::Extensions.register :lorem, auto_activate: :before_configuration do
  require 'middleman-core/extensions/lorem'
  Middleman::Extensions::Lorem
end

Middleman::Extensions.register :routing, auto_activate: :before_configuration do
  require 'middleman-core/core_extensions/routing'
  Middleman::CoreExtensions::Routing
end

Middleman::Extensions.register :collections, auto_activate: :before_configuration do
  require 'middleman-core/core_extensions/collections'
  Middleman::CoreExtensions::Collections::CollectionsExtension
end

###
# Setup Optional Extensions
###

Middleman::Extensions.register :i18n do
  require 'middleman-core/core_extensions/i18n'
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

Middleman::Extensions.register :external_pipeline do
  require 'middleman-core/extensions/external_pipeline'
  Middleman::Extensions::ExternalPipeline
end
