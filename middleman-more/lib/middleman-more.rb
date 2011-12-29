# Setup our load paths
libdir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

# Top-level Middleman object
module Middleman
  
  # Custom Renderers
  module Renderers
    autoload :Haml,         "middleman-more/renderers/haml"
    autoload :Sass,         "middleman-more/renderers/sass"
    autoload :Markdown,     "middleman-more/renderers/markdown"
    autoload :Liquid,       "middleman-more/renderers/liquid"
  end
  
  module Extensions
    # Compass framework for Sass
    autoload :Compass,             "middleman-more/core_extensions/compass"
    
    # Sprockets 2
    autoload :Sprockets,           "middleman-more/core_extensions/sprockets"
    
    # RelativeAssets allow any asset path in dynamic templates to be either
    # relative to the root of the project or use an absolute URL.
    autoload :RelativeAssets,      "middleman-more/extensions/relative_assets"

    # AssetHost allows you to setup multiple domains to host your static
    # assets. Calls to asset paths in dynamic templates will then rotate
    # through each of the asset servers to better spread the load.
    autoload :AssetHost,           "middleman-more/extensions/asset_host"

    # CacheBuster adds a query string to assets in dynamic templates to avoid
    # browser caches failing to update to your new content.
    autoload :CacheBuster,         "middleman-more/extensions/cache_buster"

    # AutomaticImageSizes inspects the images used in your dynamic templates
    # and automatically adds width and height attributes to their HTML
    # elements.
    autoload :AutomaticImageSizes, "middleman-more/extensions/automatic_image_sizes"

    # MinifyCss uses the YUI compressor to shrink CSS files
    autoload :MinifyCss,           "middleman-more/extensions/minify_css"

    # MinifyJavascript uses the YUI compressor to shrink JS files
    autoload :MinifyJavascript,    "middleman-more/extensions/minify_javascript"
  end
end