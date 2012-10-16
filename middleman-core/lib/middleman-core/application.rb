# Using Tilt for templating
require "tilt"

# Use ActiveSupport JSON
require "active_support/json"
require "active_support/core_ext/integer/inflections"
require "active_support/core_ext/float/rounding"

# Simple callback library
require "middleman-core/vendor/hooks-0.2.0/lib/hooks"

require "middleman-core/configuration"
require "middleman-core/sitemap"
require "middleman-core/core_extensions"
require "middleman-core/rack/interface"

# Core Middleman Class
module Middleman
  class Application
    # Global configuration
    include Configuration::Global

    # Uses callbacks
    include Hooks

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

    # Where to build output files
    # @return [String]
    config.define_setting :build_dir,   "build", 'Where to build output files'

    # Default prefix for building paths. Used by HTML helpers and Compass.
    # @return [String]
    config.define_setting :http_prefix, "/", 'Default prefix for building paths'

    # Default layout name
    # @return [String, Symbold]
    config.define_setting :layout, :_auto_layout, 'Default layout name'

    # Ready (all loading and parsing of extensions complete) hook
    define_hook :ready

    # Activate custom features and extensions
    include Middleman::CoreExtensions::Extensions

    # Manage Ruby string encodings
    include Middleman::CoreExtensions::RubyEncoding

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

    # Global configuration
    include Rack::Interface

    # Initialize the Middleman project
    def initialize(&block)
      # Evaluate a passed block if given
      instance_exec(&block) if block_given?

      config[:source] = ENV["MM_SOURCE"] if ENV["MM_SOURCE"]

      super

      run_hook :ready
    end

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

    delegate :mime_type, :to => ::Middleman::Util
    
    # CSSPIE HTC File
    ::Middleman::Util.mime_type('htc', 'text/x-component')

    # Let's serve all HTML as UTF-8
    ::Middleman::Util.mime_type('html', 'text/html; charset=utf-8')
    ::Middleman::Util.mime_type('htm', 'text/html; charset=utf-8')

    # The list of added Rack middleware
    #
    # @return [Array]
    def middleware
      @middleware ||= []
    end 

    # Use Rack middleware
    #
    # @param [Class] app Middleware module
    # @return [void]
    def use(app, *args, &block)
      middleware << [app, args, block]
    end

    # The list of added Rack maps
    #
    # @return [Array]
    def mappings
      @mappings ||= []
    end
    
    # Add Rack App mapped to specific path
    #
    # @param [String] map Path to map
    # @return [void]
    def map(map, &block)
      mappings << [map, block]
    end

    class FileNotFound < RuntimeError; end

    # Accessor for current path
    # @return [String]
    attr_accessor :current_path

    def render(request_path)
      logger.debug "== Request: #{request_path}"
      start_time = Time.now

      request_path = full_path(request_path)

      # Get the resource object for this path
      resource = sitemap.find_resource_by_destination_path(request_path)

      # Return 404 if not in sitemap
      if !resource || resource.ignored?
        raise ::Middleman::Application::FileNotFound
      end

      if !resource.template?
        return [nil, nil, resource.source_file]
      end

      # Write out the contents of the page
      output = resource.render do
        self.current_path = resource.destination_path
      end

      # End the request
      logger.debug "== Finishing Request: #{current_path} (#{(Time.now - start_time).round(2)}s)"

      [output, resource.mime_type, nil]
    end

  end
end
