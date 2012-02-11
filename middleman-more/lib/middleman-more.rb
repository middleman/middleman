# Setup our load paths
libdir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "middleman-core"

# Top-level Middleman object
module Middleman
  
  # Custom Renderers
  module Renderers
    autoload :Haml,         "middleman-more/renderers/haml"
    autoload :Sass,         "middleman-more/renderers/sass"
    autoload :Markdown,     "middleman-more/renderers/markdown"
    autoload :Liquid,       "middleman-more/renderers/liquid"
    autoload :Slim,         "middleman-more/renderers/slim"
  end
  
  # Core (automatic) extensions
  module CoreExtensions
    # Compass framework for Sass
    autoload :Compass,      "middleman-more/core_extensions/compass"
    
    # Sprockets 2
    autoload :Sprockets,    "middleman-more/core_extensions/sprockets"
  end
  
  # User-activatable extendions
  module Extensions
    # RelativeAssets allow any asset path in dynamic templates to be either
    # relative to the root of the project or use an absolute URL.
    autoload :RelativeAssets,      "middleman-more/extensions/relative_assets"

    # CacheBuster adds a query string to assets in dynamic templates to avoid
    # browser caches failing to update to your new content.
    autoload :CacheBuster,         "middleman-more/extensions/cache_buster"

    # MinifyCss uses the YUI compressor to shrink CSS files
    autoload :MinifyCss,           "middleman-more/extensions/minify_css"

    # MinifyJavascript uses the YUI compressor to shrink JS files
    autoload :MinifyJavascript,    "middleman-more/extensions/minify_javascript"

    # GZIP assets during build
    autoload :GzipAssets,    "middleman-more/extensions/gzip_assets"
  end
  
  # Setup renderers
  require "coffee_script"
  Base.register Middleman::Renderers::Haml
  Base.register Middleman::Renderers::Sass
  Base.register Middleman::Renderers::Markdown
  Base.register Middleman::Renderers::Liquid
  Base.register Middleman::Renderers::Slim

  # Compass framework
  Base.register Middleman::CoreExtensions::Compass

  # Sprockets asset handling
  Base.register Middleman::CoreExtensions::Sprockets
  
  # Register the optional extensions
  Extensions.register(:cache_buster) { 
    ::Middleman::Extensions::CacheBuster }
  Extensions.register(:minify_css) { 
    ::Middleman::Extensions::MinifyCss }
  Extensions.register(:minify_javascript) {
    ::Middleman::Extensions::MinifyJavascript }
  Extensions.register(:relative_assets) {
    ::Middleman::Extensions::RelativeAssets }
  Extensions.register(:gzip_assets) {
    ::Middleman::Extensions::GzipAssets }
end
