require "middleman-core"

# Setup our load paths
libdir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

module Middleman::More
  
  # Setup extension
  class << self

    # Once registered
    def registered(app, options={})
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

      # Setup default helpers
      require "middleman-more/core_extensions/default_helpers"
      Middleman::Application.register Middleman::CoreExtensions::DefaultHelpers

      # Setup asset path pipeline
      require "middleman-more/core_extensions/assets"
      Middleman::Application.register Middleman::CoreExtensions::Assets

      # i18n
      require "middleman-more/core_extensions/i18n"
      Middleman::Application.register Middleman::CoreExtensions::I18n
      
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

      # AssetHost allows you to setup multiple domains to host your static
      # assets. Calls to asset paths in dynamic templates will then rotate
      # through each of the asset servers to better spread the load.
      Middleman::Extensions.register(:asset_host) do
        require "middleman-more/extensions/asset_host"
        Middleman::Extensions::AssetHost 
      end

      # Provide Apache-style index.html files for directories
      Middleman::Extensions.register(:directory_indexes) do
        require "middleman-more/extensions/directory_indexes"
        Middleman::Extensions::DirectoryIndexes 
      end

      # Lorem provides a handful of helpful prototyping methods to generate
      # words, paragraphs, fake images, names and email addresses.
      require "middleman-more/extensions/lorem"
      Middleman::Application.register Middleman::Extensions::Lorem

      # AutomaticImageSizes inspects the images used in your dynamic templates
      # and automatically adds width and height attributes to their HTML
      # elements.
      Middleman::Extensions.register(:automatic_image_sizes) do
        require "middleman-more/extensions/automatic_image_sizes"
        Middleman::Extensions::AutomaticImageSizes
      end
    end
  end
end

Middleman::Application.register Middleman::More