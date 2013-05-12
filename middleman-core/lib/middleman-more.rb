module Middleman
  module More

    # Setup extension
    class << self

      # Once registered
      def registered(app, options={})
        ###
        # Setup Core Extensions
        ###
        
        require "middleman-core/templates"
        require "middleman-more/templates/smacss"

        begin
          # Setup default helpers
          require "middleman-more/core_extensions/default_helpers"
          Middleman::CoreExtensions::DefaultHelpers.new(app)
        rescue LoadError
          $stderr.puts "Default helpers not installed: #{$!}"
        end

        require "i18n"
        app.after_configuration do
          # This is for making the tests work - since the tests
          # don't completely reload middleman, I18n.load_path can get
          # polluted with paths from other test app directories that don't
          # exist anymore.
          ::I18n.load_path.delete_if {|path| path =~ %r{tmp/aruba}}
          ::I18n.reload!
        end if ENV["TEST"]

        require "middleman-more/core_extensions/i18n"
        Middleman::CoreExtensions::Internationalization.register(:i18n)

        # Compass framework
        begin
          require "compass"
          require "middleman-more/core_extensions/compass"
          Middleman::CoreExtensions::Compass.new(app)
        rescue LoadError
          $stderr.puts "Compass not installed: #{$!}"
        end

        ###
        # Setup Optional Extensions
        ###

        # CacheBuster adds a query string to assets in dynamic templates to
        # avoid browser caches failing to update to your new content.
        require "middleman-more/extensions/cache_buster"
        Middleman::Extensions::CacheBuster.register

        # RelativeAssets allow any asset path in dynamic templates to be either
        # relative to the root of the project or use an absolute URL.
        require "middleman-more/extensions/relative_assets"
        Middleman::Extensions::RelativeAssets.register

        # AssetHost allows you to setup multiple domains to host your static
        # assets. Calls to asset paths in dynamic templates will then rotate
        # through each of the asset servers to better spread the load.
        require "middleman-more/extensions/asset_host"
        Middleman::Extensions::AssetHost.register

        # MinifyCss compresses CSS
        require "middleman-more/extensions/minify_css"
        Middleman::Extensions::MinifyCss.register

        # MinifyJavascript compresses JS
        require "middleman-more/extensions/minify_javascript"
        Middleman::Extensions::MinifyJavascript.register

        # GZIP assets and pages during build
        require "middleman-more/extensions/gzip"
        Middleman::Extensions::Gzip.register

        # AssetHash appends a hash of the file contents to the assets filename
        # to avoid browser caches failing to update to your new content.
        require "middleman-more/extensions/asset_hash"
        Middleman::Extensions::AssetHash.register

        # Provide Apache-style index.html files for directories
        require "middleman-more/extensions/directory_indexes"
        Middleman::Extensions::DirectoryIndexes.register

        # Lorem provides a handful of helpful prototyping methods to generate
        # words, paragraphs, fake images, names and email addresses.
        require "middleman-more/extensions/lorem"
        Middleman::Extensions::Lorem.new(app)

        # AutomaticImageSizes inspects the images used in your dynamic templates
        # and automatically adds width and height attributes to their HTML
        # elements.
        require "middleman-more/extensions/automatic_image_sizes"
        Middleman::Extensions::AutomaticImageSizes.register
      end
    end
  end
end

Middleman::Application.register Middleman::More
