require 'active_support/core_ext/integer/inflections'

require 'middleman-core/contracts'
require 'middleman-core/callback_manager'
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
  MiddlewareDescriptor = Struct.new(:class, :options, :block)
  MapDescriptor = Struct.new(:path, :block)

  class Application
    extend Forwardable
    include Contracts

    class << self
      extend Forwardable
      def_delegator :config, :define_setting

      # Global configuration for the whole Middleman project.
      # @return [ConfigurationManager]
      def config
        @config ||= ::Middleman::Configuration::ConfigurationManager.new
      end

      # Root project directory (overwritten in middleman build/server)
      # @return [String]
      def root
        r = ENV['MM_ROOT'] ? ENV['MM_ROOT'].dup : ::Middleman::Util.current_directory
        r.encode!('UTF-8', 'UTF-8-MAC') if RUBY_PLATFORM =~ /darwin/
        r
      end

      # Pathname-addressed root
      def root_path
        Pathname(root)
      end
    end

    Contract ::Middleman::ConfigContext
    attr_reader :config_context

    Contract ::Middleman::Sitemap::Store
    attr_reader :sitemap

    # An anonymous subclass of ::Middleman::TemplateContext
    attr_reader :template_context_class

    # An instance of the above anonymouse class.
    attr_reader :generic_template_context

    Contract ::Middleman::Configuration::ConfigurationManager
    attr_reader :config

    Contract ::Middleman::ExtensionManager
    attr_reader :extensions

    Contract SetOf[MiddlewareDescriptor]
    attr_reader :middleware

    Contract SetOf[MapDescriptor]
    attr_reader :mappings

    # Which port preview should start on.
    # @return [Fixnum]
    define_setting :port, 4567, 'The preview server port'

    # Which server name should be used
    # @return [NilClass, String]
    define_setting :server_name, nil, 'The server name of preview server'

    # Which bind address the preview server should use
    # @return [NilClass, String]
    define_setting :bind_address, nil, 'The bind address of the preview server'

    # Whether to serve the preview server over HTTPS.
    # @return [Boolean]
    define_setting :https, false, 'Serve the preview server over SSL/TLS'

    # The (optional) path to the SSL cert to use for the preview server.
    # @return [String]
    define_setting :ssl_certificate, nil, 'Path to an X.509 certificate to use for the preview server'

    # The (optional) private key for the certificate in :ssl_certificate.
    # @return [String]
    define_setting :ssl_private_key, nil, "Path to an RSA private key for the preview server's certificate"

    # Name of the source directory
    # @return [String]
    define_setting :source, 'source', 'Name of the source directory'

    # If we should not run the sitemap.
    # @return [Boolean]
    define_setting :disable_sitemap, false, 'If we should not run the sitemap.'

    # If we should exit before ready event.
    # @return [Boolean]
    define_setting :exit_before_ready, false, 'If we should exit before ready event.'

    # Middleman mode. Defaults to :server, set to :build by the build process
    # @return [String]
    define_setting :mode, :server, 'Middleman mode. Defaults to :server'

    # Middleman environment. Defaults to :development
    # @return [String]
    define_setting :environment, ((ENV['MM_ENV'] && ENV['MM_ENV'].to_sym) || :development), 'Middleman environment. Defaults to :development', import: proc { |s| s.to_sym }

    # Which file should be used for directory indexes
    # @return [String]
    define_setting :index_file,  'index.html', 'Which file should be used for directory indexes'

    # Whether to strip the index file name off links to directory indexes
    # @return [Boolean]
    define_setting :strip_index_file, true, 'Whether to strip the index file name off links to directory indexes'

    # Whether to include a trailing slash when stripping the index file
    # @return [Boolean]
    define_setting :trailing_slash, true, 'Whether to include a trailing slash when stripping the index file'

    # Location of javascripts within source.
    # @return [String]
    define_setting :js_dir,      'javascripts', 'Location of javascripts within source'

    # Location of stylesheets within source.
    # @return [String]
    define_setting :css_dir,     'stylesheets', 'Location of stylesheets within source'

    # Location of images within source. Used by HTML helpers.
    # @return [String]
    define_setting :images_dir,  'images', 'Location of images within source'

    # Location of fonts within source.
    # @return [String]
    define_setting :fonts_dir,   'fonts', 'Location of fonts within source'

    # Location of layouts within source. Used by renderers.
    # @return [String]
    define_setting :layouts_dir, 'layouts', 'Location of layouts within source'

    # Where to build output files
    # @return [String]
    define_setting :build_dir,   'build', 'Where to build output files'

    # Default prefix for building paths. Used by HTML helpers.
    # @return [String]
    define_setting :http_prefix, '/', 'Default prefix for building paths'

    # Default layout name
    # @return [String]
    define_setting :layout, :_auto_layout, 'Default layout name'

    # Which file extensions have a layout by default.
    # @return [Array.<String>]
    define_setting :extensions_with_layout, %w(.htm .html .xhtml .php), 'Which file extensions have a layout by default.'

    # Which file extensions are "assets."
    # @return [Array.<String>]
    define_setting :asset_extensions, %w(.css .png .jpg .jpeg .webp .svg .svgz .js .gif .ttf .otf .woff .woff2 .eot .ico .map), 'Which file extensions are treated as assets.'

    # Default string encoding for templates and output.
    # @return [String]
    define_setting :encoding, 'utf-8', 'Default string encoding for templates and output'

    # Should Padrino include CRSF tag
    # @return [Boolean]
    define_setting :protect_from_csrf, false, 'Should Padrino include CRSF tag'

    # Set to automatically convert some characters into a directory
    define_setting :automatic_directory_matcher, nil, 'Set to automatically convert some characters into a directory'

    # Setup callbacks which can exclude paths from the sitemap
    define_setting :ignored_sitemap_matchers, {
      # Files starting with an underscore, but not a double-underscore
      partials: proc do |file|
        ignored = false

        file[:relative_path].ascend do |f|
          if f.basename.to_s =~ %r{^_[^_]}
            ignored = true
            break
          end
        end

        ignored
      end,

      layout: ->(file, app) {
        file[:relative_path].to_s.start_with?('layout.', app.config[:layouts_dir] + '/')
      }
    }, 'Callbacks that can exclude paths from the sitemap'

    define_setting :skip_build_clean, proc { |p| [/\.git/].any? { |r| p =~ r } }, 'Whether some paths should not be removed during a clean build.'

    define_setting :cli_options, {}, 'Options from the Command Line.'

    define_setting :watcher_disable, false, 'If the Listen watcher should not run'
    define_setting :watcher_force_polling, false, 'If the Listen watcher should run in polling mode'
    define_setting :watcher_latency, nil, 'The Listen watcher latency'
    define_setting :watcher_wait_for_delay, 0.5, 'The Listen watcher delay between calls when changes exist'

    # Delegate convenience methods off to their implementations
    def_delegator :"::Middleman::Logger", :singleton, :logger
    def_delegator :"::Middleman::Util", :instrument
    def_delegators :"self.class", :root, :root_path
    def_delegators :@generic_template_context, :link_to, :image_tag, :asset_path
    def_delegators :@extensions, :activate
    def_delegators :config, :define_setting

    # Initialize the Middleman project
    def initialize(&block)
      # Search the root of the project for required files
      $LOAD_PATH.unshift(root) unless $LOAD_PATH.include?(root)

      ::Middleman::Util.instrument 'application.setup' do
        @callbacks = ::Middleman::CallbackManager.new
        @callbacks.install_methods!(self, [
                                      :initialized,
                                      :configure,
                                      :before_extensions,
                                      :before_instance_block,
                                      :before_sitemap,
                                      :before_configuration,
                                      :after_configuration,
                                      :after_configuration_eval,
                                      :ready,
                                      :before_build,
                                      :after_build,
                                      :before_shutdown,
                                      :before, # Before Rack requests
                                      :before_render,
                                      :after_render,
                                      :before_server,
                                      :reload
                                    ])

        @middleware = Set.new
        @mappings = Set.new

        @template_context_class = Class.new(Middleman::TemplateContext)
        @generic_template_context = @template_context_class.new(self)
        @config_context = ConfigContext.new(self, @template_context_class)

        # Setup the default values from calls to set before initialization
        @config = ::Middleman::Configuration::ConfigurationManager.new
        @config.load_settings(self.class.config.all_settings)

        config[:source] = ENV['MM_SOURCE'] if ENV['MM_SOURCE']

        # TODO, make this less global
        ::Middleman::FileRenderer.cache.clear
        ::Middleman::TemplateRenderer.cache.clear
      end

      execute_callbacks(:before_extensions)

      @extensions = ::Middleman::ExtensionManager.new(self)

      execute_callbacks(:before_instance_block)

      # Evaluate a passed block if given
      config_context.instance_exec(&block) if block_given?

      apply_cli_options

      execute_callbacks(:before_sitemap)

      # Initialize the Sitemap
      @sitemap = ::Middleman::Sitemap::Store.new(self)

      ::Middleman::Extension.clear_after_extension_callbacks

      # Before config is parsed, before extensions get to it.
      execute_callbacks(:initialized)

      # Before config is parsed. Mostly used for extensions.
      execute_callbacks(:before_configuration)

      # Eval config.
      evaluate_configuration!

      # Run any `configure` blocks for the current environment.
      execute_callbacks([:configure, config[:environment]])

      # Run any `configure` blocks for the current mode.
      execute_callbacks([:configure, config[:mode]])

      apply_cli_options

      # Post parsing, pre-extension callback
      execute_callbacks(:after_configuration_eval)

      if Object.const_defined?(:Encoding)
        Encoding.default_external = config[:encoding]
      end

      prune_tilt_templates!

      # After extensions have worked after_config
      execute_callbacks(:after_configuration)

      # Everything is stable
      execute_callbacks(:ready) unless config[:exit_before_ready]
    end

    def apply_cli_options
      config[:cli_options].each do |k, v|
        setting = config.setting(k.to_sym)
        next unless setting

        v = setting.options[:import].call(v) if setting.options[:import]

        config[k.to_sym] = v
      end
    end

    # Eval config
    def evaluate_configuration!
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
      return unless File.exist? env_config

      logger.debug "== Reading: #{config[:environment]} config"
      config_context.instance_eval File.read(env_config), env_config, 1
    end

    # Clean up missing Tilt exts
    def prune_tilt_templates!
      ::Tilt.default_mapping.lazy_map.each_key do |key|
        begin
          ::Tilt[".#{key}"]
        rescue LoadError, NameError
          ::Tilt.default_mapping.lazy_map.delete(key)
        end
      end
    end

    # Whether we're in a specific mode
    # @param [Symbol] key
    # @return [Boolean]
    Contract Symbol => Bool
    def mode?(key)
      config[:mode] == key
    end

    # Whether we're in server mode
    # @return [Boolean] If we're in dev mode
    Contract Bool
    def server?
      mode?(:server)
    end

    # Whether we're in build mode
    # @return [Boolean] If we're in dev mode
    Contract Bool
    def build?
      mode?(:build)
    end

    # Whether we're in a specific environment
    # @param [Symbol] key
    # @return [Boolean]
    Contract Symbol => Bool
    def environment?(key)
      config[:environment] == key
    end

    # Backwards compatible helper. What the current environment is.
    # @return [Symbol]
    Contract Symbol
    def environment
      config[:environment]
    end

    # Backwards compatible helper. Whether we're in dev mode.
    # @return [Boolean]
    Contract Bool
    def development?
      environment?(:development)
    end

    # Backwards compatible helper. Whether we're in production mode.
    # @return [Boolean]
    Contract Bool
    def production?
      environment?(:production)
    end

    # Backwards compatible helper. The full path to the default source dir.
    Contract Pathname
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

    # Let everyone know we're shutting down.
    def shutdown!
      execute_callbacks(:before_shutdown)
    end

    # Set attributes (global variables)
    #
    # @deprecated Prefer accessing settings through "config".
    #
    # @param [Symbol] key Name of the attribue
    # @param value Attribute value
    # @return [void]
    def set(key, value=nil, &block)
      logger.warn "Warning: `set :#{key}` is deprecated. Use `config[:#{key}] =` instead."

      value = block if block_given?
      config[key] = value
    end

    # Work around this bug: http://bugs.ruby-lang.org/issues/4521
    # where Ruby will call to_s/inspect while printing exception
    # messages, which can take a long time (minutes at full CPU)
    # if the object is huge or has cyclic references, like this.
    def to_s
      "#<Middleman::Application:0x#{object_id}>"
    end
    alias inspect to_s # Ruby 2.0 calls inspect for NoMethodError instead of to_s
  end
end
