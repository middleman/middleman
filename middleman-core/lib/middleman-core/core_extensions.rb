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
require 'middleman-core/core_extensions/front_matter'

# External helpers looks in the helpers/ folder for helper modules
require 'middleman-core/core_extensions/external_helpers'

# Extended version of Padrino's rendering
require 'middleman-core/core_extensions/rendering'

# Pass custom options to views
require 'middleman-core/core_extensions/routing'

# Catch and show exceptions at the Rack level
require 'middleman-core/core_extensions/show_exceptions'

# Setup default helpers
require 'middleman-more/core_extensions/default_helpers'

require 'middleman-more/core_extensions/i18n'

# Compass framework
begin
  require 'middleman-more/core_extensions/compass'
rescue LoadError
end

###
# Setup Optional Extensions
###

# CacheBuster adds a query string to assets in dynamic templates to
# avoid browser caches failing to update to your new content.
require 'middleman-more/extensions/cache_buster'
Middleman::Extensions::CacheBuster.register

# RelativeAssets allow any asset path in dynamic templates to be either
# relative to the root of the project or use an absolute URL.
require 'middleman-more/extensions/relative_assets'
Middleman::Extensions::RelativeAssets.register

# AssetHost allows you to setup multiple domains to host your static
# assets. Calls to asset paths in dynamic templates will then rotate
# through each of the asset servers to better spread the load.
require 'middleman-more/extensions/asset_host'
Middleman::Extensions::AssetHost.register

# MinifyCss compresses CSS
require 'middleman-more/extensions/minify_css'
Middleman::Extensions::MinifyCss.register

# MinifyJavascript compresses JS
require 'middleman-more/extensions/minify_javascript'
Middleman::Extensions::MinifyJavascript.register

# GZIP assets and pages during build
require 'middleman-more/extensions/gzip'
Middleman::Extensions::Gzip.register

# AssetHash appends a hash of the file contents to the assets filename
# to avoid browser caches failing to update to your new content.
require 'middleman-more/extensions/asset_hash'
Middleman::Extensions::AssetHash.register

# Provide Apache-style index.html files for directories
require 'middleman-more/extensions/directory_indexes'
Middleman::Extensions::DirectoryIndexes.register

# Lorem provides a handful of helpful prototyping methods to generate
# words, paragraphs, fake images, names and email addresses.
require 'middleman-more/extensions/lorem'

# AutomaticImageSizes inspects the images used in your dynamic templates
# and automatically adds width and height attributes to their HTML
# elements.
require 'middleman-more/extensions/automatic_image_sizes'
Middleman::Extensions::AutomaticImageSizes.register

# AutomaticAltTags uses the file name of the `image_tag` to generate
# a default `:alt` value.
require 'middleman-more/extensions/automatic_alt_tags'
Middleman::Extensions::AutomaticAltTags.register
