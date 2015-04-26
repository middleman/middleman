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

require 'middleman-core/contracts'

require 'middleman-core/sitemap/store'

require 'middleman-core/configuration'

require 'middleman-core/extension_manager'
require 'middleman-core/core_extensions'

require 'middleman-core/config_context'
require 'middleman-core/file_renderer'
require 'middleman-core/template_renderer'

# Core Middleman Class
module Middleman
  MiddlewareDescriptor = Struct.new(:class, :options, :block)
  MapDescriptor = Struct.new(:path, :block)

  class Application
    extend Forwardable
    include Contracts

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

    define_hook :before_shutdown

    define_hook :before_render
    define_hook :after_render

    # Which host preview should start on.
    # @return [Fixnum]
    config.define_setting :host, '0.0.0.0', 'The preview server host'

    # Which port preview should start on.
    # @return [Fixnum]
    config.define_setting :port, 4567, 'The preview server port'

    # Name of the source directory
    # @return [String]
    config.define_setting :source, 'source', 'Name of the source directory'

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
      # Files starting with an underscore, but not a double-underscore
      partials: proc { |file|
        ignored = false

        file[:relative_path].ascend do |f|
          if f.basename.to_s.match %r{^_[^_]}
            ignored = true
            break
          end
        end

        ignored
      },

      layout: proc { |file, _sitemap_app|
        file[:relative_path].to_s.start_with?('layout.') ||
          file[:relative_path].to_s.start_with?('layouts/')
      }
    }, 'Callbacks that can exclude paths from the sitemap'

    config.define_setting :watcher_disable, false, 'If the Listen watcher should not run'
    config.define_setting :watcher_force_polling, false, 'If the Listen watcher should run in polling mode'
    config.define_setting :watcher_latency, nil, 'The Listen watcher latency'

    attr_reader :config_context
    attr_reader :sitemap
    attr_reader :cache
    attr_reader :template_context_class
    attr_reader :config
    attr_reader :generic_template_context
    attr_reader :extensions
    attr_reader :sources

    Contract SetOf[MiddlewareDescriptor]
    attr_reader :middleware

    Contract SetOf[MapDescriptor]
    attr_reader :mappings

    # Reference to Logger singleton
    def_delegator :"::Middleman::Logger", :singleton, :logger
    def_delegator :"::Middleman::Util", :instrument
    def_delegators :"self.class", :root, :root_path
    def_delegators :@generic_template_context, :link_to, :image_tag, :asset_path
    def_delegators :@extensions, :activate

    # Initialize the Middleman project
    def initialize(&block)
      # Search the root of the project for required files
      $LOAD_PATH.unshift(root) unless $LOAD_PATH.include?(root)

      @middleware = Set.new
      @mappings = Set.new

      @template_context_class = Class.new(Middleman::TemplateContext)
      @generic_template_context = @template_context_class.new(self)
      @config_context = ConfigContext.new(self, @template_context_class)

      ::Middleman::FileRenderer.cache.clear
      ::Middleman::TemplateRenderer.cache.clear

      # Setup the default values from calls to set before initialization
      @config = ::Middleman::Configuration::ConfigurationManager.new
      @config.load_settings(self.class.config.all_settings)

      config[:source] = ENV['MM_SOURCE'] if ENV['MM_SOURCE']

      @extensions = ::Middleman::ExtensionManager.new(self)

      # Evaluate a passed block if given
      config_context.instance_exec(&block) if block_given?

      @extensions.auto_activate(:before_sitemap)

      # Initialize the Sitemap
      @sitemap = ::Middleman::Sitemap::Store.new(self)

      if Object.const_defined?(:Encoding)
        Encoding.default_internal = config[:encoding]
        Encoding.default_external = config[:encoding]
      end

      ::Middleman::Extension.clear_after_extension_callbacks

      @extensions.auto_activate(:before_configuration)

      run_hook :initialized

      run_hook :before_configuration

      evaluate_configuration

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

      @extensions.activate_all

      run_hook :after_configuration
      config_context.execute_after_configuration_callbacks

      run_hook :ready
      @config_context.execute_ready_callbacks
    end

    def evaluate_configuration
      # Check for and evaluate local configuration in `config.rb`
      config_rb = File.join(root, 'config.rb')
      if File.exist? config_rb
        logger.debug '== Reading: Local config: config.rb'
        config_context.instance_eval File.read(config_rb), config_rb, 1
      else
        # Check for and evaluate local configuration in `middleman.rb`
        middleman_rb = File.join(root, 'middleman.rb')
        if File.exist? middleman_rb
          logger.debug '== Reading: Local middleman: middleman.rb'
          config_context.instance_eval File.read(middleman_rb), middleman_rb, 1
        end
      end

      env_config = File.join(root, 'environments', "#{config[:environment]}.rb")
      if File.exist? env_config
        logger.debug "== Reading: #{config[:environment]} config"
        config_context.instance_eval File.read(env_config), env_config, 1
      end

      # Run any `configure` blocks for the current environment.
      config_context.execute_configure_callbacks(config[:environment])

      # Run any `configure` blocks for the current mode.
      config_context.execute_configure_callbacks(config[:mode])
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

    # Backwards compatible helper. What the current environment is.
    # @return [Symbol]
    def environment
      config[:environment]
    end

    # Backwards compatible helper. Whether we're in dev mode.
    # @return [Boolean]
    def development?
      environment?(:development)
    end

    # Backwards compatible helper. Whether we're in production mode.
    # @return [Boolean]
    def production?
      environment?(:production)
    end

    # Backwards compatible helper. The full path to the default source dir.
    def source_dir
      Pathname(File.join(root, config[:source]))
    end

    # Use Rack middleware
    #
    # @param [Class] middleware Middleware module
    # @return [void]
    # Contract Any, Args[Any], Maybe[Proc] => Any
    def use(middleware, *args, &block)
      @middleware << MiddlewareDescriptor.new(middleware, args, block)
    end

    # Add Rack App mapped to specific path
    #
    # @param [String] map Path to map
    # @return [void]
    Contract String, Proc => Any
    def map(map, &block)
      @mappings << MapDescriptor.new(map, block)
    end

    def shutdown!
      run_hook :before_shutdown
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
