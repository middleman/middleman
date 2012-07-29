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
          app.define_hook :after_configuration
          app.define_hook :before_configuration
          app.define_hook :build_config
          app.define_hook :development_config

          if ENV["AUTOLOAD_SPROCKETS"]
            app.set :autoload_sprockets, (ENV["AUTOLOAD_SPROCKETS"] == "true")
          else
            app.set :autoload_sprockets, true
          end

          app.extend ClassMethods
          app.send :include, InstanceMethods
          app.delegate :configure, :to => :"self.class"
          
          ::Middleman::Extension.add_hooks do
            set_callback :activate, :after, :autoregister_config_callbacks
            
            def autoregister_config_callbacks
              if respond_to?(:on_build) && app.build?
                app.build_config(&method(:on_build))
              end
              
              if respond_to?(:in_dev) && app.development?
                app.build_config(&method(:in_dev))
              end
              
              if respond_to?(:before_configuration)
                app.before_configuration(&method(:before_configuration))
              end
              
              if respond_to?(:after_configuration)
                app.after_configuration(&method(:after_configuration))
              end
            end
          end
          
        end
        alias :included :registered
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

        # Alias `extensions` to access registered extensions
        #
        # @return [Array<Module>]
        def extensions
          @extensions ||= []
        end

        # Register a new extension
        #
        # @param [Module] extension Extension modules to register
        # @param [Hash] options Per-extension options hash
        # @return [void]
        def register(extension, options={}, &block)
          @extensions ||= []
          @extensions += [extension]

          extend extension
          if extension.respond_to?(:registered)
            if extension.method(:registered).arity === 1
              extension.registered(self, &block)
            else
              extension.registered(self, options, &block)
            end
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
        def activate(ext, options={}, &block)
          extension_container = if ext.is_a?(Module)
            ext
          else
            ::Middleman::Extensions.load(ext.to_sym)
          end
      
          if extension_container.nil?
            logger.warn "== Unknown Extension: #{ext}"
          elsif extension_container.is_a? Class
            logger.debug "== Activating: #{ext}"
            extension_container.new(self, options, &block)
          elsif extension_container.is_a? Module
            logger.debug "== Activating: #{ext}"
            self.class.register(extension_container, options, &block)
          end
        end

        # Load features before starting server
        def initialize
          super

          self.class.inst = self
          run_hook :before_configuration

          # Search the root of the project for required files
          $LOAD_PATH.unshift(root)

          # Check for and evaluate local configuration
          local_config = File.join(root, "config.rb")
          if File.exists? local_config
            logger.debug "== Reading:  Local config"
            instance_eval File.read(local_config), local_config, 1
          end

          if autoload_sprockets
            begin
              require "middleman-sprockets"
              activate(:sprockets)
            rescue LoadError
            end
          end

          run_hook :build_config if build?
          run_hook :development_config if development?

          run_hook :after_configuration

          logger.debug "Loaded extensions:"
          self.class.extensions.each do |ext|
            logger.debug "== Extension: #{ext}"
          end
        end
      end
    end
  end
end
