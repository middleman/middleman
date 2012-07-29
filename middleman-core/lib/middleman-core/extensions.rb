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
  
  require 'active_support/descendants_tracker'
  require 'active_support/callbacks'
  require 'active_support/core_ext/module/delegation'
  
  # Auto-registration class, in the style of Rails::Engine
  class Extension
    include ::ActiveSupport::Callbacks
    extend ::ActiveSupport::DescendantsTracker
    
    class_attribute :autoregister
    class_attribute :extension_name
    
    class << self
      def config_options(opts={})
        @_config_options ||= {}
        @_config_options.merge!(opts)
        @_config_options
      end
      
      def helpers(&block)
        @_helpers ||= Set.new
        @_helpers << block if block_given?
        @_helpers
      end
    
      def add_hooks(&block)
        class_eval(&block)
      end
      
      def inherited(base)
        super
        
        if base.autoregister.nil? || base.autoregister === true
          extension_name = base.extension_name || generate_extension_name(base.name.split("::").last)
          ::Middleman::Extensions.register(extension_name) { base }
        end
      end
      
    protected
      def generate_extension_name(class_or_module)
        ActiveSupport::Inflector.underscore(class_or_module).tr("/", "_").to_sym
      end
    end
    
    attr_reader :app, :options
    
    delegate :logger, :to => :app
    
    define_callbacks :activate
    
    def initialize(app, options={}, &block)
      @app     = app
      @options = options
      
      self.class.config_options.each do |k,v|
        @app.set(k, v)
      end
      
      self.class.helpers.each do |h|
        @app.class.helpers(&h)
      end
      
      run_callbacks :activate do
        # Derp
      end
    end
  end
end
