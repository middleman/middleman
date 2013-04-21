require "active_support/core_ext/class/attribute"

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

      begin
        require "middleman-more"
      rescue LoadError
      end

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
        ::Gem::Specification.latest_specs
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
    end

    attr_accessor :app, :options

    def initialize(klass, options_hash={})
      @_helpers = []

      @options = self.class.config.dup
      @options.finalize!

      options_hash.each do |k, v|
        @options[k] = v
      end

      yield @options if block_given?

      ext = self
      klass.initialized do
        ext.app = self
        
        (ext.class.defined_helpers || []).each do |m|
          ext.app.helpers(m)
        end
        
        if ext.respond_to?(:initialized)
          ext.initialized
        end
      end

      klass.after_configuration do
        if ext.respond_to?(:after_configuration)
          ext.after_configuration
        end

        if ext.respond_to?(:manipulate_resource_list)
          ext.app.sitemap.register_resource_list_manipulator(ext.class.extension_name, ext)
        end
      end
    end
  end
end
