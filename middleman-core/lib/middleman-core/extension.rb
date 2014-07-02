require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/class/attribute'
require 'middleman-core/configuration'

module Middleman
  class Extension
    class_attribute :supports_multiple_instances, instance_reader: false, instance_writer: false
    class_attribute :defined_helpers, instance_reader: false, instance_writer: false
    class_attribute :ext_name, instance_reader: false, instance_writer: false

    class << self
      def config
        @_config ||= ::Middleman::Configuration::ConfigurationManager.new
      end

      def option(key, default=nil, description=nil)
        config.define_setting(key, default, description)
      end

      # Add helpers to the global Middleman application.
      # This accepts either a list of modules to add on behalf
      # of this extension, or a block whose contents will all
      # be used as helpers in a new module.
      def helpers(*m, &block)
        self.defined_helpers ||= []

        if block_given?
          mod = Module.new
          mod.module_eval(&block)
          m = [mod]
        end

        self.defined_helpers += m
      end

      def extension_name
        ext_name || name.underscore.split('/').last.to_sym
      end

      def register(n=extension_name)
        ::Middleman::Extensions.register(n, self)
      end

      def activate
        new(::Middleman::Application)
      end

      def clear_after_extension_callbacks
        @_extension_activation_callbacks = {}
      end

      def after_extension_activated(name, &block)
        @_extension_activation_callbacks ||= {}
        @_extension_activation_callbacks[name] ||= []
        @_extension_activation_callbacks[name] << block if block_given?
      end

      def activated_extension(instance)
        name = instance.class.extension_name
        return unless @_extension_activation_callbacks && @_extension_activation_callbacks[name]
        @_extension_activation_callbacks[name].each do |block|
          block.arity == 1 ? block.call(instance) : block.call
        end
      end
    end

    attr_accessor :options
    attr_reader :app

    delegate :after_extension_activated, to: :"::Middleman::Extension"

    def initialize(klass, options_hash={}, &block)
      @_helpers = []
      @klass = klass

      setup_options(options_hash, &block)
      setup_app_reference_when_available

      # Bind app hooks to local methods
      bind_before_configuration
      bind_after_configuration
      bind_before_build
      bind_after_build
    end

    def app=(app)
      @app = app

      (self.class.defined_helpers || []).each do |m|
        app.class.send(:include, m)
      end
    end

    protected

    def setup_options(options_hash)
      @options = self.class.config.dup
      @options.finalize!

      options_hash.each do |k, v|
        @options[k] = v
      end

      yield @options if block_given?
    end

    def setup_app_reference_when_available
      ext = self

      @klass.initialized do
        ext.app = self
      end

      @klass.instance_available do
        ext.app ||= self
      end
    end

    def bind_before_configuration
      ext = self
      return unless ext.respond_to?(:before_configuration)

      @klass.before_configuration do
        ext.before_configuration
      end
    end

    def bind_after_configuration
      ext = self
      @klass.after_configuration do
        ext.after_configuration if ext.respond_to?(:after_configuration)

        # rubocop:disable IfUnlessModifier
        if ext.respond_to?(:manipulate_resource_list)
          ext.app.sitemap.register_resource_list_manipulator(ext.class.extension_name, ext)
        end
      end
    end

    def bind_before_build
      ext = self
      return unless ext.respond_to?(:before_build)

      @klass.before_build do |builder|
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

      @klass.after_build do |builder|
        if ext.method(:after_build).arity == 1
          ext.after_build(builder)
        else
          ext.after_build
        end
      end
    end
  end
end
