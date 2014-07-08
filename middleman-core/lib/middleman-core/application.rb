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

require 'middleman-core/sitemap/store'

require 'middleman-core/configuration'

require 'middleman-core/extension_manager'
require 'middleman-core/core_extensions'

require 'middleman-core/config_context'
require 'middleman-core/file_renderer'
require 'middleman-core/template_renderer'

# Core Middleman Class
module Middleman
  class Application
    extend Forwardable

    class << self
      # Global configuration for the whole Middleman project.
      # @return [ConfigurationManager]
      def config
        @config ||= ::Middleman::Configuration::ConfigurationManager.new
      end

      # Root project directory (overwritten in middleman build/server)
      # @return [String]
      def root
        ENV['MM_ROOT'] || Dir.pwd
      end

      # Pathname-addressed root
      def root_path
        Pathname(root)
      end
    end

    # Uses callbacks
    include Hooks
    include Hooks::InstanceHooks

    define_hook :initialized
    define_hook :after_configuration
    define_hook :before_configuration

    # Before request hook
    define_hook :before

    # Ready (all loading and parsing of extensions complete) hook
    define_hook :ready

    # Runs before the build is started
    define_hook :before_build

    # Runs after the build is finished
    define_hook :after_build

    define_hook :before_render
    define_hook :after_render

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

    # Set to automatically convert some characters into a directory
    config.define_setting :automatic_directory_matcher, nil, 'Set to automatically convert some characters into a directory'

    # Setup callbacks which can exclude paths from the sitemap
    config.define_setting :ignored_sitemap_matchers, {
      # dotfiles and folders in the root
      root_dotfiles: proc { |file| file.start_with?('.') },

      # Files starting with an dot, but not .htaccess
      source_dotfiles: proc { |file|
        file =~ %r{/\.} && file !~ %r{/\.(htaccess|htpasswd|nojekyll)}
      },

      # Files starting with an underscore, but not a double-underscore
      partials: proc { |file| file =~ %r{/_[^_]} },

      layout: proc { |file, sitemap_app|
        file.start_with?(File.join(sitemap_app.config[:source], 'layout.')) || file.start_with?(File.join(sitemap_app.config[:source], 'layouts/'))
      }
    }, 'Callbacks that can exclude paths from the sitemap'

    config.define_setting :autoload_sprockets, true, 'Automatically load sprockets at startup?'
    config[:autoload_sprockets] = (ENV['AUTOLOAD_SPROCKETS'] == 'true') if ENV['AUTOLOAD_SPROCKETS']

    attr_reader :config_context
    attr_reader :sitemap
    attr_reader :cache
    attr_reader :template_context_class
    attr_reader :config
    attr_reader :generic_template_context
    attr_reader :extensions
    attr_reader :middleware
    attr_reader :mappings

    # Reference to Logger singleton
    def_delegator :"::Middleman::Logger", :singleton, :logger
    def_delegator :"::Middleman::Util", :instrument
    def_delegators :"self.class", :root, :root_path
    def_delegators :@generic_template_context, :link_to, :image_tag, :asset_path
    
    # Initialize the Middleman project
    def initialize(&block)
      # Search the root of the project for required files
      $LOAD_PATH.unshift(root) unless $LOAD_PATH.include?(root)

      @middleware = []
      @mappings = []

      @template_context_class = Class.new(Middleman::TemplateContext)
      @generic_template_context = @template_context_class.new(self)
      @config_context = ConfigContext.new(self, @template_context_class)

      ::Middleman::FileRenderer.cache.clear
      ::Middleman::TemplateRenderer.cache.clear

      # Setup the default values from calls to set before initialization
      @config = ::Middleman::Configuration::ConfigurationManager.new
      @config.load_settings(self.class.config.all_settings)

      @extensions = ::Middleman::ExtensionManager.new(self)
      @extensions.auto_activate(:before_sitemap)

      # Initialize the Sitemap
      @sitemap = ::Middleman::Sitemap::Store.new(self)

      if Object.const_defined?(:Encoding)
        Encoding.default_internal = config[:encoding]
        Encoding.default_external = config[:encoding]
      end

      config[:source] = ENV['MM_SOURCE'] if ENV['MM_SOURCE']

      ::Middleman::Extension.clear_after_extension_callbacks

      @extensions.auto_activate(:before_configuration)

      if config[:autoload_sprockets]
        begin
          require 'middleman-sprockets'
          @extensions.activate :sprockets
        rescue LoadError
          # It's OK if somebody is using middleman-core without middleman-sprockets
        end
      end

      run_hook :initialized

      run_hook :before_configuration

      evaluate_configuration(&block)

      # This is for making the tests work - since the tests
      # don't completely reload middleman, I18n.load_path can get
      # polluted with paths from other test app directories that don't
      # exist anymore.
      if ENV['TEST']
        ::I18n.load_path.delete_if { |path| path =~ %r{tmp/aruba} }
        ::I18n.reload!
      end

      # Clean up missing Tilt exts
      Tilt.mappings.each do |key, _|
        begin
          Tilt[".#{key}"]
        rescue LoadError, NameError
          Tilt.mappings.delete(key)
        end
      end

      run_hook :after_configuration
      config_context.execute_after_configuration_callbacks

      @extensions.activate_all

      run_hook :ready
      @config_context.execute_ready_callbacks
    end

    def evaluate_configuration(&block)
      # Evaluate a passed block if given
      config_context.instance_exec(&block) if block_given?

      # Check for and evaluate local configuration in `config.rb`
      local_config = File.join(root, 'config.rb')
      if File.exist? local_config
        logger.debug '== Reading: Local config'
        config_context.instance_eval File.read(local_config), local_config, 1
      end

      env_config = File.join(root, 'environments', "#{config[:environment]}.rb")
      if File.exist? env_config
        logger.debug "== Reading: #{config[:environment]} config"
        config_context.instance_eval File.read(env_config), env_config, 1
      end

      config_context.execute_configure_callbacks(config[:environment])
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

    # Use Rack middleware
    #
    # @param [Class] middleware Middleware module
    # @return [void]
    def use(middleware, *args, &block)
      @middleware << [middleware, args, block]
    end

    # Add Rack App mapped to specific path
    #
    # @param [String] map Path to map
    # @return [void]
    def map(map, &block)
      @mappings << [map, block]
    end

    # Work around this bug: http://bugs.ruby-lang.org/issues/4521
    # where Ruby will call to_s/inspect while printing exception
    # messages, which can take a long time (minutes at full CPU)
    # if the object is huge or has cyclic references, like this.
    def to_s
      "#<Middleman::Application:0x#{object_id}>"
    end
    alias_method :inspect, :to_s # Ruby 2.0 calls inspect for NoMethodError instead of to_s

  end
end
