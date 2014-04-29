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
      # parameter:
      #
      #     Middleman::Extensions.register(:my_extension, MyExtension)
      #
      # Or return it from a block:
      #
      #     Middleman::Extensions.register(:my_extension) do
      #       require 'my_extension'
      #       MyExtension
      #     end
      #
      # @param [Symbol] name The name of the extension
      # @param [Module] namespace The extension module
      # @yield Instead of passing a module in namespace, you can provide
      #        a block which returns your extension module. This gives
      #        you the ability to require other files only when the
      #        extension is activated.
      def register(name, namespace=nil, &block)
        # If we've already got an extension registered under this name, bail out
        if registered.key?(name.to_sym)
          raise "There is already an extension registered with the name '#{name}'"
        end

        registered[name.to_sym] = if block_given?
          block
        elsif namespace && namespace.ancestors.include?(::Middleman::Extension)
          namespace
        else
          raise 'You must provide a Middleman::Extension or a block that returns a Middleman::Extension'
        end
      end

      # Load an extension by name, evaluating block definition if necessary.
      def load(name)
        name = name.to_sym

        unless registered.key?(name)
          raise "Unknown Extension: #{name}. Check the name and make sure you have referenced the extension's gem in your Gemfile."
        end

        extension = registered[name]
        if extension.is_a?(Proc)
          extension = extension.call
          registered[name] = extension
        end

        unless extension.ancestors.include?(::Middleman::Extension)
          raise "Tried to activate old-style extension: #{name}. They are no longer supported."
        end

        # Set the extension's name to whatever it was registered as.
        extension.ext_name = name

        extension
      end
    end
  end

  # Where to look in gems for extensions to auto-register. Since most extensions are
  # called out in a Gemfile, this is really only useful for template extensions that get
  # used by "middleman init".
  EXTENSION_FILE = File.join('lib', 'middleman_extension.rb') unless const_defined?(:EXTENSION_FILE)

  class << self
    # Automatically load extensions from available RubyGems
    # which contain the EXTENSION_FILE
    #
    # @private
    def load_extensions_in_path
      require 'rubygems'

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
      File.exist?(full_path)
    end
  end
end

require 'middleman-core/extension'
