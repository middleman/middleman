require 'active_support/core_ext/class/attribute'
require 'middleman-core/configuration'
require 'middleman-core/contracts'

module Middleman
  # Middleman's Extension API provides the ability to add functionality to Middleman
  # and to customize existing features. Internally, most features in Middleman are
  # implemented as extensions. A good way to figure out how to write your own extension
  # is to look at the source of the built-in extensions or popular extension gems like
  # `middleman-blog` or `middleman-syntax`.
  #
  # The most basic extension looks like:
  #
  #     class MyFeature < Middleman::Extension
  #       def initialize(app, options_hash={}, &block)
  #         super
  #       end
  #     end
  #     ::Middleman::Extensions.register(:my_feature, MyFeature)
  #
  # A more complicated example might look like:
  #
  #     class MyFeature < Middleman::Extension
  #       option :my_option, 'cool', 'A very cool option'
  #
  #       def initialize(app, options_hash={}, &block)
  #         super
  #         puts "My option is #{options.my_option}"
  #       end
  #
  #       def after_configuration
  #         puts "The project has been configured"
  #       end
  #
  #       def manipulate_resource_list(resources)
  #         resources.each do |resource|
  #           # Make all .jpg's get built or served with a .jpeg extension.
  #           if resource.ext == '.jpg'
  #             resource.destination_path = resource.destination_path.sub('.jpg', '.jpeg')
  #           end
  #         end
  #       end
  #     end
  #
  #     ::Middleman::Extensions.register :my_feature do
  #       MyFeature
  #     end
  #
  # Extensions can add helpers (via {Extension.helpers}), add to the sitemap or change it (via {#manipulate_resource_list}), or run
  # arbitrary code at different parts of the Middleman application's lifecycle. They can have options (defined via {Extension.option} and accessed via {#options}).
  #
  # Common lifecycle events can be handled by extensions simply by implementing an appropriately-named method:
  #
  # * {#after_configuration}
  # * {#after_build}
  # * {#before_build}
  #
  # There are also some less common hooks that can be listened to from within an extension's `initialize` method:
  #
  # * `app.before_render {|body, path, locs, template_class| ... }` - Manipulate template sources before they are rendered.
  # * `app.after_render {|content, path, locs, template_class| ... }` - Manipulate output text after a template has been rendered. It is also common to install a Rack middleware to do this instead.
  # * `app.ready { ... }` - Run code once Middleman is ready to serve or build files (after `after_configuration`).
  # * `app.compass_config { |compass_config| ... }` - Manipulate the Compass configuration after it has been set up.
  #
  # @see http://middlemanapp.com/advanced/custom/ Middleman Custom Extensions Documentation
  class Extension
    extend Forwardable
    include Contracts

    def_delegator :@app, :logger

    # @!attribute supports_multiple_instances
    #   @!scope class
    #   @return [Boolean] whether or not an extension can be activated multiple times, generating multiple instances of the extension.
    #   By default extensions can only be activated once in a project. This is an advanced option.
    class_attribute :supports_multiple_instances, instance_reader: false, instance_writer: false

    # @!attribute defined_helpers
    #   @!scope class
    #   @api private
    #   @return [Array<Module>] a list of all the helper modules this extension provides. Set these using {#helpers}.
    class_attribute :defined_helpers, instance_reader: false, instance_writer: false

    # @!attribute ext_name
    #   @!scope class
    #   @return [Symbol] the name this extension is registered under. This is the symbol used to activate the extension.
    class_attribute :ext_name, instance_reader: false, instance_writer: false

    # @!attribute resource_list_manipulator_priority
    #   @!scope class
    #   @return [Numeric] the priority for this extension's `manipulate_resource_list` method, if it has one.
    #   @see Middleman::Sitemap::Store#register_resource_list_manipulator
    class_attribute :resource_list_manipulator_priority, instance_reader: false, instance_writer: false

    class << self
      # @api private
      # @return [Middleman::Configuration::ConfigurationManager] The defined options for this extension.
      def config
        @_config ||= ::Middleman::Configuration::ConfigurationManager.new
      end

      # Add an option to this extension.
      # @see Middleman::Configuration::ConfigurationManager#define_setting
      # @example
      #   option :compress, false, 'Whether to compress the output'
      # @param [Symbol] key The name of the option
      # @param [Object] default The default value for the option
      # @param [String] description A human-readable description of what the option does
      def option(key, default=nil, description=nil)
        config.define_setting(key, default, description)
      end

      # Declare helpers to be added the global Middleman application.
      # This accepts either a list of modules to add on behalf
      # of this extension, or a block whose contents will all
      # be used as helpers in a new module.
      # @example With a block:
      #   helpers do
      #     def my_helper
      #       "I helped!"
      #     end
      #   end
      # @example With modules:
      #   helpers FancyHelpers, PlainHelpers
      # @param [Array<Module>] modules An optional list of modules to add as helpers
      # @param [Proc] block A block which will be evaluated to create a new helper module
      # @return [void]
      def helpers(*modules, &block)
        self.defined_helpers ||= []

        if block_given?
          mod = Module.new
          mod.module_eval(&block)
          modules = [mod]
        end

        self.defined_helpers += modules
      end

      # Reset all {Extension.after_extension_activated} callbacks.
      # @api private
      # @return [void]
      def clear_after_extension_callbacks
        @_extension_activation_callbacks = {}
      end

      # Register to run a block after a named extension is activated.
      # @param [Symbol] name The name the extension was registered under
      # @param [Proc] block A callback to run when the named extension is activated
      # @return [void]
      def after_extension_activated(name, &block)
        @_extension_activation_callbacks ||= {}
        @_extension_activation_callbacks[name] ||= []
        @_extension_activation_callbacks[name] << block if block_given?
      end

      # Notify that a particular extension has been activated and run all
      # registered {Extension.after_extension_activated} callbacks.
      # @api private
      # @param [Middleman::Extension] instance Activated extension instance
      # @return [void]
      def activated_extension(instance)
        name = instance.class.ext_name
        return unless @_extension_activation_callbacks && @_extension_activation_callbacks.key?(name)
        @_extension_activation_callbacks[name].each do |block|
          block.arity == 1 ? block.call(instance) : block.call
        end
      end
    end

    # @return [Middleman::Configuration::ConfigurationManager] options for this extension instance.
    attr_reader :options

    # @return [Middleman::Application] the Middleman application instance.
    attr_reader :app

    # @!method after_extension_activated(name, &block)
    #   Register to run a block after a named extension is activated.
    #   @param [Symbol] name The name the extension was registered under
    #   @param [Proc] block A callback to run when the named extension is activated
    #   @return [void]
    def_delegator :"::Middleman::Extension", :after_extension_activated

    # Extensions are instantiated when they are activated.
    # @param [Middleman::Application] app The Middleman::Application instance
    # @param [Hash] options_hash The raw options hash. Subclasses should not manipulate this directly - it will be turned into {#options}.
    # @yield An optional block that can be used to customize options before the extension is activated.
    # @yieldparam [Middleman::Configuration::ConfigurationManager] options Extension options
    def initialize(app, options_hash={}, &block)
      @_helpers = []
      @app = app

      setup_options(options_hash, &block)

      # Bind app hooks to local methods
      bind_before_configuration
      bind_after_configuration
      bind_before_build
      bind_after_build
    end

    # @!method before_configuration
    #   Respond to the `before_configuration` event.
    #   If a `before_configuration` method is implemented, that method will be run before `config.rb` is run.
    #   @note Because most extensions are activated from within `config.rb`, they *will not run* any `before_configuration` hook.

    # @!method after_configuration
    #   Respond to the `after_configuration` event.
    #   If an `after_configuration` method is implemented, that method will be run before `config.rb` is run.

    # @!method before_build
    #   Respond to the `before_build` event.
    #   If an `before_build` method is implemented, that method will be run before the builder runs.

    # @!method after_build
    #   Respond to the `after_build` event.
    #   If an `after_build` method is implemented, that method will be run after the builder runs.

    # @!method manipulate_resource_list(resources)
    #   Manipulate the resource list by transforming or adding {Sitemap::Resource}s.
    #   Sitemap manipulation is a powerful way of interacting with a project, since it can modify each {Sitemap::Resource} or generate new {Sitemap::Resources}. This method is used in a pipeline where each sitemap manipulator is run in turn, with each one being fed the output of the previous manipulator. See the source of built-in Middleman extensions like {Middleman::Extensions::DirectoryIndexes} and {Middleman::Extensions::AssetHash} for examples of how to use this.
    #   @note This method *must* return the full set of resources, because its return value will be used as the new sitemap.
    #   @see http://middlemanapp.com/advanced/sitemap/ Sitemap Documentation
    #   @see Sitemap::Store
    #   @see Sitemap::Resource
    #   @param [Array<Sitemap::Resource>] resources A list of all the resources known to the sitemap.
    #   @return [Array<Sitemap::Resource>] The transformed list of resources.

    private

    # @yield An optional block that can be used to customize options before the extension is activated.
    # @yieldparam Middleman::Configuration::ConfigurationManager] options Extension options
    def setup_options(options_hash)
      @options = self.class.config.dup
      @options.finalize!

      options_hash.each do |k, v|
        @options[k] = v
      end

      yield @options if block_given?
    end

    def bind_before_configuration
      @app.before_configuration(&method(:before_configuration)) if respond_to?(:before_configuration)
    end

    def bind_after_configuration
      ext = self
      @app.after_configuration do
        ext.after_configuration if ext.respond_to?(:after_configuration)

        if ext.respond_to?(:manipulate_resource_list)
          ext.app.sitemap.register_resource_list_manipulator(ext.class.ext_name, ext, ext.class.resource_list_manipulator_priority)
        end
      end
    end

    def bind_before_build
      ext = self
      return unless ext.respond_to?(:before_build)

      @app.before_build do |builder|
        if ext.method(:before_build).arity == 1
          ext.before_build(builder)
        else
          ext.before_build
        end
      end
    end

    def bind_after_build
      ext = self
      return unless ext.respond_to?(:after_build)

      @app.after_build do |builder|
        if ext.method(:after_build).arity == 1
          ext.after_build(builder)
        else
          ext.after_build
        end
      end
    end
  end
end
