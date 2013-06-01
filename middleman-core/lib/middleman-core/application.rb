# Using Tilt for templating
require "tilt"

# i18n Built-in
require "i18n"

# Use ActiveSupport JSON
require "active_support/json"
require "active_support/core_ext/integer/inflections"
require "active_support/core_ext/float/rounding"

# Simple callback library
require "vendored-middleman-deps/hooks-0.2.0/lib/hooks"

require "middleman-core/sitemap"

require "middleman-core/configuration"
require "middleman-core/core_extensions"

# Core Middleman Class
module Middleman
  class Application
    # Global configuration
    include Configuration::Global

    # Uses callbacks
    include Hooks

    # Before request hook
    define_hook :before

    # Ready (all loading and parsing of extensions complete) hook
    define_hook :ready

    # Runs after the build is finished
    define_hook :after_build

    # Mix-in helper methods. Accepts either a list of Modules
    # and/or a block to be evaluated
    # @return [void]
    def self.helpers(*extensions, &block)
      class_eval(&block)   if block_given?
      include(*extensions) if extensions.any?
    end
    delegate :helpers, :to => :"self.class"

    # Root project directory (overwritten in middleman build/server)
    # @return [String]
    def self.root
      ENV["MM_ROOT"] || Dir.pwd
    end
    delegate :root, :to => :"self.class"

    # Pathname-addressed root
    def self.root_path
      Pathname(root)
    end
    delegate :root_path, :to => :"self.class"

    # Name of the source directory
    # @return [String]
    config.define_setting :source,      "source", 'Name of the source directory'

    # Middleman environment. Defaults to :development, set to :build by the build process
    # @return [String]
    config.define_setting :environment, ((ENV['MM_ENV'] && ENV['MM_ENV'].to_sym) || :development), 'Middleman environment. Defaults to :development, set to :build by the build process'

    # Which file should be used for directory indexes
    # @return [String]
    config.define_setting :index_file,  "index.html", 'Which file should be used for directory indexes'

    # Whether to strip the index file name off links to directory indexes
    # @return [Boolean]
    config.define_setting :strip_index_file, true, 'Whether to strip the index file name off links to directory indexes'

    # Whether to include a trailing slash when stripping the index file
    # @return [Boolean]
    config.define_setting :trailing_slash, true, 'Whether to include a trailing slash when stripping the index file'

    # Location of javascripts within source.
    # @return [String]
    config.define_setting :js_dir,      "javascripts", 'Location of javascripts within source'

    # Location of stylesheets within source. Used by Compass.
    # @return [String]
    config.define_setting :css_dir,     "stylesheets", 'Location of stylesheets within source'

    # Location of images within source. Used by HTML helpers and Compass.
    # @return [String]
    config.define_setting :images_dir,  "images", 'Location of images within source'

    # Location of fonts within source. Used by Compass.
    # @return [String]
    config.define_setting :fonts_dir,   "fonts", 'Location of fonts within source'

    # Location of partials within source. Used by renderers.
    # @return [String]
    config.define_setting :partials_dir,   "", 'Location of partials within source'

    # Location of layouts within source. Used by renderers.
    # @return [String]
    config.define_setting :layouts_dir, "layouts", 'Location of layouts within source'

    # Where to build output files
    # @return [String]
    config.define_setting :build_dir,   "build", 'Where to build output files'

    # Default prefix for building paths. Used by HTML helpers and Compass.
    # @return [String]
    config.define_setting :http_prefix, "/", 'Default prefix for building paths'

    # Default layout name
    # @return [String, Symbold]
    config.define_setting :layout, :_auto_layout, 'Default layout name'

    # Default string encoding for templates and output.
    # @return [String]
    config.define_setting :encoding, "utf-8", 'Default string encoding for templates and output'

    # Activate custom features and extensions
    include Middleman::CoreExtensions::Extensions

    # Basic Rack Request Handling
    register Middleman::CoreExtensions::Request

    # Handle exceptions
    register Middleman::CoreExtensions::ShowExceptions

    # Add Watcher Callbacks
    register Middleman::CoreExtensions::FileWatcher

    # Activate Data package
    register Middleman::CoreExtensions::Data

    # Setup custom rendering
    register Middleman::CoreExtensions::Rendering

    # Parse YAML from templates. Must be before sitemap so sitemap
    # extensions see updated frontmatter!
    register Middleman::CoreExtensions::FrontMatter

    # Sitemap
    register Middleman::Sitemap

    # Setup external helpers
    register Middleman::CoreExtensions::ExternalHelpers

    # with_layout and page routing
    include Middleman::CoreExtensions::Routing

    # Initialize the Middleman project
    def initialize(&block)
      # Clear the static class cache
      cache.clear

      # Setup the default values from calls to set before initialization
      self.class.config.load_settings(self.class.superclass.config.all_settings)

      if Object.const_defined?(:Encoding)
        Encoding.default_internal = config[:encoding]
        Encoding.default_external = config[:encoding]
      end

      # Evaluate a passed block if given
      instance_exec(&block) if block_given?

      config[:source] = ENV["MM_SOURCE"] if ENV["MM_SOURCE"]

      super
    end

    # Shared cache instance
    #
    # @private
    # @return [Middleman::Util::Cache] The cache
    def self.cache
      @_cache ||= ::Tilt::Cache.new
    end
    delegate :cache, :to => :"self.class"

    # Whether we're in development mode
    # @return [Boolean] If we're in dev mode
    def development?; config[:environment] == :development; end

    # Whether we're in build mode
    # @return [Boolean] If we're in build mode
    def build?; config[:environment] == :build; end

    # The full path to the source directory
    #
    # @return [String]
    def source_dir
      File.join(root, config[:source])
    end

    delegate :logger, :instrument, :to => ::Middleman::Util

    # Work around this bug: http://bugs.ruby-lang.org/issues/4521
    # where Ruby will call to_s/inspect while printing exception
    # messages, which can take a long time (minutes at full CPU)
    # if the object is huge or has cyclic references, like this.
    def to_s
      "#<Middleman::Application:0x#{object_id}>"
    end
    alias :inspect :to_s # Ruby 2.0 calls inspect for NoMethodError instead of to_s

    # Expand a path to include the index file if it's a directory
    #
    # @private
    # @param [String] path Request path
    # @return [String] Path with index file if necessary
    def full_path(path)
      resource = sitemap.find_resource_by_destination_path(path)

      if !resource
        # Try it with /index.html at the end
        indexed_path = File.join(path.sub(%r{/$}, ''), config[:index_file])
        resource = sitemap.find_resource_by_destination_path(indexed_path)
      end

      if resource
        '/' + resource.destination_path
      else
        '/' + Middleman::Util.normalize_path(path)
      end
    end

  end
end

Middleman::CoreExtensions::DefaultHelpers.activate

Middleman::CoreExtensions::Internationalization.register(:i18n)

if defined?(Middleman::CoreExtensions::Compass)
  Middleman::CoreExtensions::Compass.activate
end

Middleman::Extensions::Lorem.activate
