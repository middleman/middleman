# Using Tilt for templating
require "tilt"

# Use ActiveSupport JSON
require "active_support/json"
require "active_support/core_ext/integer/inflections"
require "active_support/core_ext/float/rounding"

# Simple callback library
require "middleman-core/vendor/hooks-0.2.0/lib/hooks"

require "middleman-core/sitemap"

require "middleman-core/core_extensions"

# Core Middleman Class
module Middleman
  class Application
    # Uses callbacks
    include Hooks

    # Before request hook
    define_hook :before

    # Ready (all loading and parsing of extensions complete) hook
    define_hook :ready

    class << self

      # Mix-in helper methods. Accepts either a list of Modules
      # and/or a block to be evaluated
      # @return [void]
      def helpers(*extensions, &block)
        class_eval(&block)   if block_given?
        include(*extensions) if extensions.any?
      end

      # Access class-wide defaults
      #
      # @private
      # @return [Hash] Hash of default values
      def defaults
        @defaults ||= {}
      end

      # Set class-wide defaults
      #
      # @param [Symbol] key Unique key name
      # @param value Default value
      # @return [void]
      def set(key, value=nil, &block)
        @defaults ||= {}
        @defaults[key] = value

        @inst.set(key, value, &block) if @inst
      end
    end

    delegate :helpers, :to => :"self.class"

    # Set attributes (global variables)
    #
    # @param [Symbol] key Name of the attribue
    # @param value Attribute value
    # @return [void]
    def set(key, value=nil, &block)
      setter = "#{key}=".to_sym
      self.class.send(:attr_accessor, key) if !respond_to?(setter)
      value = block if block_given?
      send(setter, value)
    end

    # Root project directory (overwritten in middleman build/server)
    # @return [String]
    set :root,        ENV["MM_ROOT"] || Dir.pwd

    # Pathname-addressed root
    def root_path
      @_root_path ||= Pathname.new(root)
    end

    # Name of the source directory
    # @return [String]
    set :source,      "source"

    # Middleman environment. Defaults to :development, set to :build by the build process
    # @return [String]
    set :environment, (ENV['MM_ENV'] && ENV['MM_ENV'].to_sym) || :development

    # Which file should be used for directory indexes
    # @return [String]
    set :index_file,  "index.html"

    # Whether to strip the index file name off links to directory indexes
    # @return [Boolean]
    set :strip_index_file, true

    # Whether to include a trailing slash when stripping the index file
    # @return [Boolean]
    set :trailing_slash, true

    # Location of javascripts within source.
    # @return [String]
    set :js_dir,      "javascripts"

    # Location of stylesheets within source. Used by Compass.
    # @return [String]
    set :css_dir,     "stylesheets"

    # Location of images within source. Used by HTML helpers and Compass.
    # @return [String]
    set :images_dir,  "images"

    # Location of fonts within source. Used by Compass.
    # @return [String]
    set :fonts_dir,   "fonts"

    # Where to build output files
    # @return [String]
    set :build_dir,   "build"

    # Default prefix for building paths. Used by HTML helpers and Compass.
    # @return [String]
    set :http_prefix, "/"

    # Default string encoding for templates and output.
    # @return [String]
    set :encoding,    "utf-8"

    # Whether to catch and display exceptions
    # @return [Boolean]
    set :show_exceptions, true

    # Default layout name
    # @return [String, Symbold]
    set :layout, :_auto_layout

    # Activate custom features and extensions
    include Middleman::CoreExtensions::Extensions

    # Manage Ruby string encodings
    include Middleman::CoreExtensions::RubyEncoding

    # Basic Rack Request Handling
    register Middleman::CoreExtensions::Request

    # Handle exceptions
    register Middleman::CoreExtensions::ShowExceptions

    # Add Builder Callbacks
    register Middleman::CoreExtensions::Builder

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
    register Middleman::CoreExtensions::Routing

    # Initialize the Middleman project
    def initialize(&block)
      # Clear the static class cache
      cache.clear

      # Setup the default values from calls to set before initialization
      self.class.superclass.defaults.each { |k,v| set(k,v) }

      # Evaluate a passed block if given
      instance_exec(&block) if block_given?

      set :source, ENV["MM_SOURCE"] if ENV["MM_SOURCE"]

      super
    end

    # Shared cache instance
    #
    # @private
    # @return [Middleman::Util::Cache] The cache
    def self.cache
      @_cache ||= ::Middleman::Util::Cache.new
    end
    delegate :cache, :to => :"self.class"

    # Whether we're in development mode
    # @return [Boolean] If we're in dev mode
    def development?; environment == :development; end

    # Whether we're in build mode
    # @return [Boolean] If we're in build mode
    def build?; environment == :build; end

    # Backwards compatibilty with old Sinatra template interface
    #
    # @return [Middleman::Application]
    def settings
      self
    end

    # The full path to the source directory
    #
    # @return [String]
    def source_dir
      File.join(root, source)
    end

    delegate :logger, :instrument, :to => ::Middleman::Util

    # Work around this bug: http://bugs.ruby-lang.org/issues/4521
    # where Ruby will call to_s/inspect while printing exception
    # messages, which can take a long time (minutes at full CPU)
    # if the object is huge or has cyclic references, like this.
    def to_s
      "#<Middleman::Application:0x#{object_id}>"
    end

    # Expand a path to include the index file if it's a directory
    #
    # @private
    # @param [String] path Request path
    # @return [String] Path with index file if necessary
    def full_path(path)
      resource = sitemap.find_resource_by_destination_path(path)

      if !resource
        # Try it with /index.html at the end
        indexed_path = File.join(path.sub(%r{/$}, ''), index_file)
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
