# Middleman provides an extension API which allows you to hook into the
# lifecycle of a page request, or static build, and manipulate the output.
# Internal to Middleman, these extensions are called "features," but we use
# the exact same API as is made available to the public.
#
# A Middleman extension looks like this:
#
#     module MyExtension
#       class << self
#         def registered(app)
#           # My Code
#         end
#       end
#     end
#
# In your `config.rb`, you must load your extension (if it is not defined in
# that file) and call `activate`.
#
#     require "my_extension"
#     activate MyExtension
#
# This will call the `registered` method in your extension and provide you
# with the `app` parameter which is a Middleman::Application context. From here
# you can choose to respond to requests for certain paths or simply attach
# Rack middleware to the stack.
#
# The built-in features cover a wide range of functions. Some provide helper
# methods to use in your views. Some modify the output on-the-fly. And some
# apply computationally-intensive changes to your final build files.

# Namespace extensions module
module Middleman
  module CoreExtensions
    module Extensions
      # Register extension
      class << self
        # @private
        def registered(app)
          app.define_hook :initialized
          app.define_hook :instance_available
          app.define_hook :after_configuration
          app.define_hook :before_configuration
          app.define_hook :build_config
          app.define_hook :development_config

          app.config.define_setting :autoload_sprockets, true, 'Automatically load sprockets at startup?'
          app.config[:autoload_sprockets] = (ENV['AUTOLOAD_SPROCKETS'] == 'true') if ENV['AUTOLOAD_SPROCKETS']

          app.extend ClassMethods
          app.send :include, InstanceMethods
          app.delegate :configure, to: :"self.class"
        end
        alias_method :included, :registered
      end

      # Class methods
      module ClassMethods
        # Add a callback to run in a specific environment
        #
        # @param [String, Symbol] env The environment to run in
        # @return [void]
        def configure(env, &block)
          send("#{env}_config", &block)
        end

        # Register a new extension
        #
        # @param [Module] extension Extension modules to register
        # @param [Hash] options Per-extension options hash
        # @return [void]
        def register(extension, options={}, &block)
          if extension.instance_of?(Class) && extension.ancestors.include?(::Middleman::Extension)
            extension.new(self, options, &block)
          else
            extend extension
            if extension.respond_to?(:registered)
              if extension.method(:registered).arity == 1
                extension.registered(self, &block)
              else
                extension.registered(self, options, &block)
              end
            end
            extension
          end
        end
      end

      # Instance methods
      module InstanceMethods
        # This method is available in the project's `config.rb`.
        # It takes a underscore-separated symbol, finds the appropriate
        # feature module and includes it.
        #
        #     activate :lorem
        #
        # @param [Symbol, Module] ext Which extension to activate
        # @return [void]
        # rubocop:disable BlockNesting
        def activate(ext, options={}, &block)
          ext_module = if ext.is_a?(Module)
            ext
          else
            ::Middleman::Extensions.load(ext)
          end

          if ext_module.nil?
            logger.error "== Unknown Extension: #{ext}"
          else
            logger.debug "== Activating: #{ext}"

            if ext_module.instance_of? Module
              extensions[ext] = self.class.register(ext_module, options, &block)
            elsif ext_module.instance_of?(Class) && ext_module.ancestors.include?(::Middleman::Extension)
              if ext_module.supports_multiple_instances?
                extensions[ext] ||= {}
                key = "instance_#{extensions[ext].keys.length}"
                extensions[ext][key] = ext_module.new(self.class, options, &block)
              else
                if extensions[ext]
                  logger.error "== #{ext} already activated."
                else
                  extensions[ext] = ext_module.new(self.class, options, &block)
                end
              end
            end
          end
        end

        # Access activated extensions
        #
        # @return [Hash<Symbol,Middleman::Extension|Module>]
        def extensions
          @extensions ||= {}
        end

        # Load features before starting server
        def initialize
          super

          self.class.inst = self

          # Search the root of the project for required files
          $LOAD_PATH.unshift(root)

          ::Middleman::Extension.clear_after_extension_callbacks
          run_hook :initialized

          if config[:autoload_sprockets]
            begin
              require 'middleman-sprockets'
              activate(:sprockets)
            rescue LoadError
            end
          end

          run_hook :before_configuration

          # Check for and evaluate local configuration
          local_config = File.join(root, 'config.rb')
          if File.exist? local_config
            logger.debug '== Reading:  Local config'
            instance_eval File.read(local_config), local_config, 1
          end

          run_hook :build_config if build?
          run_hook :development_config if development?

          run_hook :instance_available

          # This is for making the tests work - since the tests
          # don't completely reload middleman, I18n.load_path can get
          # polluted with paths from other test app directories that don't
          # exist anymore.
          if ENV['TEST']
            ::I18n.load_path.delete_if { |path| path =~ %r{tmp/aruba} }
            ::I18n.reload!
          end

          run_hook :after_configuration

          logger.debug 'Loaded extensions:'
          extensions.each do |ext, klass|
            if ext.is_a?(Hash)
              ext.each do |k, _|
                logger.debug "== Extension: #{k}"
              end
            else
              logger.debug "== Extension: #{ext}"
            end

            ::Middleman::Extension.activated_extension(klass) if klass.is_a?(::Middleman::Extension)
          end
        end
      end
    end
  end
end
