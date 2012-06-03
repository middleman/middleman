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
  
  # Auto-registration class, in the style of Rails::Engine
  class Extension
    
    class << self
      
      def subclasses
        @subclasses ||= []
      end
    
      def extension_name(name = nil)
        @extension_name = name.to_sym if name
        @extension_name ||= generate_extension_name(self.name.split("::").last)
      end
      
      def inherited(base)
        subclasses << base
        ::Middleman::Extensions.register(base.extension_name) { base }
      end
      
      protected
        def generate_extension_name(class_or_module)
          ActiveSupport::Inflector.underscore(class_or_module).tr("/", "_").to_sym
        end
    end
    
    attr_reader :app
    attr_reader :options
    
    def initialize(app, options={}, &block)
      @app     = app
      @options = options
      
      activated(&block)
    end
    
    def activated(&block)
      autoregister_resource_list_manipulator
    end
    
    def autoregister_resource_list_manipulator
      return unless respond_to?(:manipulate_resource_list)
      
      extension = self
      app.ready do
        sitemap.register_resource_list_manipulator(
          extension.class.extension_name,
          extension
        )
      end
    end
  end
end
