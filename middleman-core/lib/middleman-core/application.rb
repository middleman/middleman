# i18n Built-in
require 'i18n'

# Don't fail on invalid locale, that's not what our current
# users expect.
::I18n.enforce_available_locales = false

# Use ActiveSupport JSON
require 'active_support/json'
require 'active_support/core_ext/integer/inflections'

# Simple callback library
require 'hooks'

# Our custom logger
require 'middleman-core/logger'

require 'middleman-core/sitemap'
require 'middleman-core/sitemap/store'

require 'middleman-core/configuration'
require 'middleman-core/core_extensions'

require 'middleman-core/config_context'
require 'middleman-core/file_renderer'
require 'middleman-core/template_renderer'

# Rack Request
require 'middleman-core/core_extensions/request'

# Custom Extension API and config.rb handling
require 'middleman-core/core_extensions/extensions'

# Core Middleman Class
module Middleman
  class Application
    # Global configuration
    include Configuration::Global

    # Uses callbacks
    include Hooks
    include Hooks::InstanceHooks

    # Before request hook
    define_hook :before

    # Ready (all loading and parsing of extensions complete) hook
    define_hook :ready

    # Runs before the build is started
    define_hook :before_build

    # Runs after the build is finished
    define_hook :after_build

    # Root project directory (overwritten in middleman build/server)
    # @return [String]
    def self.root
      ENV['MM_ROOT'] || Dir.pwd
    end
    delegate :root, to: :"self.class"

    # Pathname-addressed root
    def self.root_path
      Pathname(root)
    end
    delegate :root_path, to: :"self.class"

    # Name of the source directory
    # @return [String]
    config.define_setting :source,      'source', 'Name of the source directory'

    # Middleman mode. Defaults to :server, set to :build by the build process
    # @return [String]
    config.define_setting :mode, ((ENV['MM_ENV'] && ENV['MM_ENV'].to_sym) || :server), 'Middleman mode. Defaults to :server'

    # Middleman environment. Defaults to :development
    # @return [String]
    config.define_setting :environment, :development, 'Middleman environment. Defaults to :development'

    # Which file should be used for directory indexes
    # @return [String]
    config.define_setting :index_file,  'index.html', 'Which file should be used for directory indexes'

    # Whether to strip the index file name off links to directory indexes
    # @return [Boolean]
    config.define_setting :strip_index_file, true, 'Whether to strip the index file name off links to directory indexes'

    # Whether to include a trailing slash when stripping the index file
    # @return [Boolean]
    config.define_setting :trailing_slash, true, 'Whether to include a trailing slash when stripping the index file'

    # Location of javascripts within source.
    # @return [String]
    config.define_setting :js_dir,      'javascripts', 'Location of javascripts within source'

    # Location of stylesheets within source. Used by Compass.
    # @return [String]
    config.define_setting :css_dir,     'stylesheets', 'Location of stylesheets within source'

    # Location of images within source. Used by HTML helpers and Compass.
    # @return [String]
    config.define_setting :images_dir,  'images', 'Location of images within source'

    # Location of fonts within source. Used by Compass.
    # @return [String]
    config.define_setting :fonts_dir,   'fonts', 'Location of fonts within source'

    # Location of partials within source. Used by renderers.
    # @return [String]
    config.define_setting :partials_dir,   '', 'Location of partials within source'

    # Location of layouts within source. Used by renderers.
    # @return [String]
    config.define_setting :layouts_dir, 'layouts', 'Location of layouts within source'

    # Where to build output files
    # @return [String]
    config.define_setting :build_dir,   'build', 'Where to build output files'

    # Default prefix for building paths. Used by HTML helpers and Compass.
    # @return [String]
    config.define_setting :http_prefix, '/', 'Default prefix for building paths'

    # Default layout name
    # @return [String, Symbold]
    config.define_setting :layout, :_auto_layout, 'Default layout name'

    # Default string encoding for templates and output.
    # @return [String]
    config.define_setting :encoding, 'utf-8', 'Default string encoding for templates and output'

    # Should Padrino include CRSF tag
    # @return [Boolean]
    config.define_setting :protect_from_csrf, false, 'Should Padrino include CRSF tag'

    # Activate custom features and extensions
    include Middleman::CoreExtensions::Extensions

    # Basic Rack Request Handling
    include Middleman::CoreExtensions::Request

    # Setup custom rendering
    include Middleman::CoreExtensions::Rendering

    # Sitemap Config options and public api
    include Middleman::Sitemap

    # Reference to Logger singleton
    def logger
      ::Middleman::Logger.singleton
    end

    # New container for config.rb commands
    attr_reader :config_context

    # Reference to Sitemap
    attr_reader :sitemap

    # Template cache
    attr_reader :cache

    attr_reader :template_context_class

    attr_reader :generic_template_context
    delegate :link_to, :image_tag, :asset_path, to: :generic_template_context

    # Initialize the Middleman project
    def initialize
      @template_context_class = Class.new(Middleman::TemplateContext)
      @generic_template_context = @template_context_class.new(self)
      @config_context = ConfigContext.new(self, @template_context_class)

      ::Middleman::FileRenderer.cache.clear
      ::Middleman::TemplateRenderer.cache.clear

      # Setup the default values from calls to set before initialization
      self.class.config.load_settings(self.class.superclass.config.all_settings)

      ::Middleman::Extensions.auto_activate(:before_sitemap, self)

      # Initialize the Sitemap
      @sitemap = ::Middleman::Sitemap::Store.new(self)

      if Object.const_defined?(:Encoding)
        Encoding.default_internal = config[:encoding]
        Encoding.default_external = config[:encoding]
      end

      config[:source] = ENV['MM_SOURCE'] if ENV['MM_SOURCE']

      super
    end

    def add_to_instance(name, &func)
      define_singleton_method(name, &func)
    end

    def add_to_config_context(name, &func)
      @config_context.define_singleton_method(name, &func)
    end

    # Whether we're in server mode
    # @return [Boolean] If we're in dev mode
    def server?
      config[:mode] == :server
    end

    # Whether we're in build mode
    # @return [Boolean] If we're in dev mode
    def build?
      config[:mode] == :build
    end

    # Whether we're in a specific environment
    # @return [Boolean]
    def environment?(key)
      config[:environment] == key
    end

    # The full path to the source directory
    #
    # @return [String]
    def source_dir
      File.join(root, config[:source])
    end

    delegate :instrument, to: ::Middleman::Util

    # Work around this bug: http://bugs.ruby-lang.org/issues/4521
    # where Ruby will call to_s/inspect while printing exception
    # messages, which can take a long time (minutes at full CPU)
    # if the object is huge or has cyclic references, like this.
    def to_s
      "#<Middleman::Application:0x#{object_id}>"
    end
    alias_method :inspect, :to_s # Ruby 2.0 calls inspect for NoMethodError instead of to_s

    # Hooks clones _hooks from the class to the instance.
    # https://github.com/apotonick/hooks/blob/master/lib/hooks/instance_hooks.rb#L10
    # Middleman expects the same list of hooks for class and instance hooks:
    def _hooks
      self.class._hooks
    end
  end
end
