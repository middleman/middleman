# Using Tilt for templating
require "tilt"

# Use ActiveSupport JSON
require "active_support/json"

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
  
    # Name of the source directory
    # @return [String]
    set :source,      "source"
  
    # Middleman environment. Defaults to :development, set to :build by the build process
    # @return [String]
    set :environment, (ENV['MM_ENV'] && ENV['MM_ENV'].to_sym) || :development
  
    # Whether logging is active, disabled by default
    # @return [String]
    set :logging, false

    # Which file should be used for directory indexes
    # @return [String]
    set :index_file,  "index.html"

    # Location of javascripts within source. Used by Sprockets.
    # @return [String]
    set :js_dir,      "javascripts"
  
    # Location of stylesheets within source. Used by Compass.
    # @return [String]
    set :css_dir,     "stylesheets"
  
    # Location of images within source. Used by HTML helpers and Compass.
    # @return [String]
    set :images_dir,  "images"

    # Where to build output files
    # @return [String]
    set :build_dir,   "build"
  
    # Default prefix for building paths. Used by HTML helpers and Compass.
    # @return [String]
    set :http_prefix, "/"

    # Whether to catch and display exceptions
    # @return [Boolean]
    set :show_exceptions, true

    # Automatically loaded extensions
    # @return [Array<Symbol>]
    set :default_extensions, [ :lorem ]

    # Default layout name
    # @return [String, Symbold]
    set :layout, :_auto_layout
  
    # Activate custom features and extensions
    include Middleman::CoreExtensions::Extensions
    
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
  
    # Sitemap
    register Middleman::Sitemap
  
    # Setup external helpers
    register Middleman::CoreExtensions::ExternalHelpers
  
    # Setup default helpers
    register Middleman::CoreExtensions::DefaultHelpers
  
    # Setup asset path pipeline
    register Middleman::CoreExtensions::Assets
  
    # with_layout and page routing
    register Middleman::CoreExtensions::Routing
  
    # i18n
    register Middleman::CoreExtensions::I18n
  
    # Parse YAML from templates
    register Middleman::CoreExtensions::FrontMatter
  
    # Built-in Extensions
    
    # Provide Apache-style index.html files for directories
    Middleman::Extensions.register(:directory_indexes) do
      require "middleman-core/extensions/directory_indexes"
      Middleman::Extensions::DirectoryIndexes 
    end
    
    # Lorem provides a handful of helpful prototyping methods to generate
    # words, paragraphs, fake images, names and email addresses.
    Middleman::Extensions.register(:lorem) do
      require "middleman-core/extensions/lorem"
      Middleman::Extensions::Lorem 
    end
    
    # AutomaticImageSizes inspects the images used in your dynamic templates
    # and automatically adds width and height attributes to their HTML
    # elements.
    Middleman::Extensions.register(:automatic_image_sizes) do
      require "middleman-core/extensions/automatic_image_sizes"
      Middleman::Extensions::AutomaticImageSizes
    end
    
    # AssetHost allows you to setup multiple domains to host your static
    # assets. Calls to asset paths in dynamic templates will then rotate
    # through each of the asset servers to better spread the load.
    Middleman::Extensions.register(:asset_host) do
      require "middleman-core/extensions/asset_host"
      Middleman::Extensions::AssetHost 
    end
  
    # Initialize the Middleman project
    def initialize(&block)
      # Current path defaults to nil, used in views.
      self.current_path = nil
    
      # Clear the static class cache
      cache.clear
    
      # Setup the default values from calls to set before initialization
      self.class.superclass.defaults.each { |k,v| set(k,v) }
    
      # Evaluate a passed block if given
      instance_exec(&block) if block_given?
    
      # Build expanded source path once paths have been parsed
      path = root.dup
      source_path = ENV["MM_SOURCE"] || self.source
      path = File.join(root, source_path) unless source_path.empty?
      set :source_dir, path
    
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

    # Whether we're logging
    #
    # @return [Boolean] If we're logging
    def logging?
      logging
    end
  
    # Expand a path to include the index file if it's a directory
    #
    # @private
    # @param [String] path Request path
    # @return [String] Path with index file if necessary
    def full_path(path)
      cache.fetch(:full_path, path) do
        parts = path ? path.split('/') : []
        if parts.last.nil? || parts.last.split('.').length == 1
          path = File.join(path, index_file) 
        end
        "/" + path.sub(%r{^/}, '')
      end
    end
  
  end
  
  class << self
    # Create a new Class which is based on Middleman::Application
    # Used to create a safe sandbox into which extensions and
    # configuration can be included later without impacting
    # other classes and instances.
    #
    # @return [Class]
    def server(&block)
      @@servercounter ||= 0
      @@servercounter += 1
      const_set("MiddlemanApplication#{@@servercounter}", Class.new(Middleman::Application))
    end

    # Creates a new Rack::Server
    #
    # @param [Hash] options to pass to Rack::Server.new
    # @return [Rack::Server]
    def start_server(options={})
      opts = {
        :Port      => options[:port] || 4567,
        :Host      => options[:host] || "0.0.0.0",
        :AccessLog => []
      }

      app_class = options[:app] ||= ::Middleman.server.inst
      opts[:app] = app_class

      require "webrick"
      opts[:Logger] = WEBrick::Log::new("/dev/null", 7) if !options[:logging]
      opts[:server] = 'webrick'

      server = ::Rack::Server.new(opts)
      server.start
      server
    end
  end
end