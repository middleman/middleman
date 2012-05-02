module Middleman

  # Backwards compatibility namespace
  module Features
  end

  module CoreExtensions
    # Rack Request
    autoload :Request,        "middleman-core/core_extensions/request"
    
    # File Change Notifier
    autoload :FileWatcher,    "middleman-core/core_extensions/file_watcher"

    # In-memory Sitemap
    autoload :Sitemap,        "middleman-core/core_extensions/sitemap"

    # Add Builder callbacks
    autoload :Builder,        "middleman-core/core_extensions/builder"

    # Custom Feature API
    autoload :Extensions,     "middleman-core/core_extensions/extensions"

    # Asset Path Pipeline
    autoload :Assets,         "middleman-core/core_extensions/assets"

    # Data looks at the data/ folder for YAML files and makes them available
    # to dynamic requests.
    autoload :Data,           "middleman-core/core_extensions/data"

    # Parse YAML from templates
    autoload :FrontMatter,    "middleman-core/core_extensions/front_matter"

    # External helpers looks in the helpers/ folder for helper modules
    autoload :ExternalHelpers, "middleman-core/core_extensions/external_helpers"

    # DefaultHelpers are the built-in dynamic template helpers.
    autoload :DefaultHelpers, "middleman-core/core_extensions/default_helpers"

    # Extended version of Padrino's rendering
    autoload :Rendering,      "middleman-core/core_extensions/rendering"

    # Pass custom options to views
    autoload :Routing,        "middleman-core/core_extensions/routing"

    # Catch and show exceptions at the Rack level
    autoload :ShowExceptions, "middleman-core/core_extensions/show_exceptions"
    
    # i18n
    autoload :I18n,           "middleman-core/core_extensions/i18n"
  end
  
  module Extensions
    # Provide Apache-style index.html files for directories
    autoload :DirectoryIndexes,    "middleman-core/extensions/directory_indexes"

    # Lorem provides a handful of helpful prototyping methods to generate
    # words, paragraphs, fake images, names and email addresses.
    autoload :Lorem,               "middleman-core/extensions/lorem"

    # AutomaticImageSizes inspects the images used in your dynamic templates
    # and automatically adds width and height attributes to their HTML
    # elements.
    autoload :AutomaticImageSizes, "middleman-core/extensions/automatic_image_sizes"

    # AssetHost allows you to setup multiple domains to host your static
    # assets. Calls to asset paths in dynamic templates will then rotate
    # through each of the asset servers to better spread the load.
    autoload :AssetHost,           "middleman-core/extensions/asset_host"
  
    class << self
      def registered
        @_registered ||= {}
      end

      # Register a new extension. Choose a name which will be
      # used to activate the extension in config.rb, like this:
      #
      #     activate :my_extension
      #
      # Provide your extension module either as the namespace
      # parameter, or return it from the block:
      #
      # @param [Symbol] name The name of the extension
      # @param [Module] namespace The extension module
      # @param [String] version A RubyGems-style version string stating
      #                         the versions of middleman this extension
      #                         is compatible with.
      # @yield Instead of passing a module in namespace, you can provide
      #        a block which returns your extension module. This gives
      #        you the ability to require other files only when the
      #        extension is activated.
      def register(name, namespace=nil, version=nil, &block)
        # If we've already got a matching extension that passed the
        # version check, bail out.
        return if registered.has_key?(name.to_sym) &&
        !registered[name.to_sym].is_a?(String)

        if block_given?
          version = namespace
        end

        passed_version_check = true
        if !version.nil?
          requirement = ::Gem::Requirement.create(version)
          if !requirement.satisfied_by?(Middleman::GEM_VERSION)
            passed_version_check = false
          end
        end

        registered[name.to_sym] = if !passed_version_check
          "== #{name} failed version check. Requested #{version}, got #{Middleman::VERSION}"
        elsif block_given?
          block
        elsif namespace
          namespace
        end
      end

      def load(name)
        name = name.to_sym
        return nil unless registered.has_key?(name)

        extension = registered[name]
        if extension.is_a?(Proc)
          extension = extension.call() || nil
          registered[name] = extension
        end

        extension
      end
    end
  end

  # Where to look in gems for extensions to auto-register
  EXTENSION_FILE = File.join("lib", "middleman_extension.rb") unless const_defined?(:EXTENSION_FILE)

  class << self
    # Automatically load extensions from available RubyGems
    # which contain the EXTENSION_FILE
    #
    # @private
    def load_extensions_in_path
      if defined?(Bundler)
        Bundler.require
      else
        extensions = rubygems_latest_specs.select do |spec|
          spec_has_file?(spec, EXTENSION_FILE)
        end

        extensions.each do |spec|
          require spec.name
        end
      end
    end

    # Backwards compatible means of finding all the latest gemspecs
    # available on the system
    #
    # @private
    # @return [Array] Array of latest Gem::Specification
    def rubygems_latest_specs
      # If newer Rubygems
      if ::Gem::Specification.respond_to? :latest_specs
        ::Gem::Specification.latest_specs
      else
        ::Gem.source_index.latest_specs
      end
    end

    # Where a given Gem::Specification has a specific file. Used
    # to discover extensions and Sprockets-supporting gems.
    #
    # @private
    # @param [Gem::Specification] spec
    # @param [String] path Path to look for
    # @return [Boolean] Whether the file exists
    def spec_has_file?(spec, path)
      full_path = File.join(spec.full_gem_path, path)
      File.exists?(full_path)
    end
  end
end