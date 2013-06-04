require "active_support/core_ext/class/attribute"
require "active_support/core_ext/module/delegation"

module Middleman

  module Extensions

    class << self
      def registered
        @_registered ||= {}
      end

      # Register a new extension. Choose a name which will be
      # used to activate the extension in config.rb, like this:
      #
      #     activate :my_extension
      #
      # Provide your extension module either as the namespace
      # parameter, or return it from the block:
      #
      # @param [Symbol] name The name of the extension
      # @param [Module] namespace The extension module
      # @yield Instead of passing a module in namespace, you can provide
      #        a block which returns your extension module. This gives
      #        you the ability to require other files only when the
      #        extension is activated.
      def register(name, namespace=nil, &block)
        # If we've already got a matching extension that passed the
        # version check, bail out.
        return if registered.has_key?(name.to_sym) &&
        !registered[name.to_sym].is_a?(String)

        registered[name.to_sym] = if block_given?
          block
        elsif namespace
          namespace
        end
      end

      def load(name)
        name = name.to_sym
        return nil unless registered.has_key?(name)

        extension = registered[name]
        if extension.is_a?(Proc)
          extension = extension.call() || nil
          registered[name] = extension
        end

        extension
      end
    end
  end

  # Where to look in gems for extensions to auto-register
  EXTENSION_FILE = File.join("lib", "middleman_extension.rb") unless const_defined?(:EXTENSION_FILE)

  class << self
    # Automatically load extensions from available RubyGems
    # which contain the EXTENSION_FILE
    #
    # @private
    def load_extensions_in_path
      require "rubygems"

      extensions = rubygems_latest_specs.select do |spec|
        spec_has_file?(spec, EXTENSION_FILE)
      end

      extensions.each do |spec|
        require spec.name
      end
    end

    # Backwards compatible means of finding all the latest gemspecs
    # available on the system
    #
    # @private
    # @return [Array] Array of latest Gem::Specification
    def rubygems_latest_specs
      # If newer Rubygems
      if ::Gem::Specification.respond_to? :latest_specs
        ::Gem::Specification.latest_specs(true)
      else
        ::Gem.source_index.latest_specs
      end
    end

    # Where a given Gem::Specification has a specific file. Used
    # to discover extensions.
    #
    # @private
    # @param [Gem::Specification] spec
    # @param [String] path Path to look for
    # @return [Boolean] Whether the file exists
    def spec_has_file?(spec, path)
      full_path = File.join(spec.full_gem_path, path)
      File.exists?(full_path)
    end
  end

  class Extension
    class_attribute :supports_multiple_instances, :instance_reader => false, :instance_writer => false
    class_attribute :defined_helpers, :instance_reader => false, :instance_writer => false
    class_attribute :ext_name, :instance_reader => false, :instance_writer => false

    class << self
      def config
        @_config ||= ::Middleman::Configuration::ConfigurationManager.new
      end

      def option(key, default=nil, description=nil)
        config.define_setting(key, default, description)
      end

      def helpers(&block)
        self.defined_helpers ||= []

        m = Module.new
        m.module_eval(&block)
        self.defined_helpers << m
      end

      def extension_name
        self.ext_name || self.name.underscore.split("/").last.to_sym
      end

      def register(n=self.extension_name)
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
          block.arity == 1 ? block.call(instance) : block.call()
        end
      end
    end

    attr_accessor :options
    attr_reader :app

    delegate :after_extension_activated, :to => :"::Middleman::Extension"

    def initialize(klass, options_hash={}, &block)
      @_helpers = []
      @klass = klass

      setup_options(options_hash, &block)
      setup_app_reference_when_available

      # Bind app hooks to local methods
      bind_before_configuration
      bind_after_configuration
      bind_after_build
    end

    def app=(app)
      @app = app
      
      (self.class.defined_helpers || []).each do |m|
        app.class.send(:include, m)
      end
    end

  protected

    def setup_options(options_hash, &block)
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
      if ext.respond_to?(:before_configuration)
        @klass.before_configuration do
          ext.before_configuration
        end
      end
    end

    def bind_after_configuration
      ext = self
      @klass.after_configuration do
        if ext.respond_to?(:after_configuration)
          ext.after_configuration
        end

        if ext.respond_to?(:manipulate_resource_list)
          ext.app.sitemap.register_resource_list_manipulator(ext.class.extension_name, ext)
        end
      end
    end

    def bind_after_build
      ext = self
      if ext.respond_to?(:after_build)
        @klass.after_build do |builder|
          if ext.method(:after_build).arity === 1
            ext.after_build(builder)
          else
            ext.after_build
          end
        end
      end
    end
  end
end
