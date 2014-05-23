require 'middleman-core/extension'
require 'set'

module Middleman
  # The Extensions module is used to handle global registration and loading of Middleman Extensions.
  #
  # The application-facing extension API ({Middleman::CoreExtensions::Extensions#activate activate}, etc) is in {Middleman::CoreExtensions::Extensions} in
  # `middleman-core/core_extensions/extensions.rb`.
  module Extensions
    @registered = {}
    @auto_activate_before_configuration = Set.new

    class << self
      # @api private
      # A hash of all registered extensions. Registered extensions are not necessarily active - this
      # is the set of all extensions that are known to Middleman.
      # @return [Hash{Symbol => Class<Middleman::Extension>, Proc}] A directory of known extensions indexed by the name they were registered under. The value may be a Proc, which can be lazily called to return an extension class.
      attr_reader :registered

      # @api private
      # A list of extensions that should be automatically loaded before `config.rb` is loaded and before the `:before_configuration` hook is run. Only internal, built-in Middleman extensions should be listed here.
      attr_reader :auto_activate_before_configuration

      # Register a new extension. Choose a name which will be
      # used to activate the extension in `config.rb`, like this:
      #
      #     activate :my_extension
      #
      # Provide your extension class either as the second parameter:
      #
      #     Middleman::Extensions.register(:my_extension, MyExtension)
      #
      # Or better, return it from a block, which allows you to lazily require the implementation:
      #
      #     Middleman::Extensions.register :my_extension do
      #       require 'my_extension'
      #       MyExtension
      #     end
      #
      # @param [Symbol] name The name of the extension
      # @param [Class<Middleman::Extension>] extension_class The extension class (Must inherit from {Middleman::Extension})
      # @option options [Boolean] :auto_activate_before_configuration If set to true, this extension will be automatically
      #         activated before `config.rb` is loaded and before the `:before_configuration` hook is run.
      #         This is intended for use with built-in Middleman extensions and should not be used by third-party extensions.
      # @yield Instead of passing a module in namespace, you can provide
      #        a block which returns your extension class. This gives
      #        you the ability to require other files only when the
      #        extension is first activated.
      # @return [void]
      def register(name, extension_class=nil, options={}, &block)
        raise 'Extension name must be a symbol' unless name.is_a?(Symbol)
        # If we've already got an extension registered under this name, bail out
        raise "There is already an extension registered with the name '#{name}'" if registered.key?(name)

        # If the extension is defined with a block, grab options out of the "extension_class" parameter.
        if extension_class && block_given? && options.empty? && extension_class.is_a?(Hash)
          options = extension_class
          extension_class = nil
        end

        registered[name] = if block_given?
          block
        elsif extension_class && extension_class.ancestors.include?(::Middleman::Extension)
          extension_class
        else
          raise 'You must provide a Middleman::Extension or a block that returns a Middleman::Extension'
        end

        @auto_activate_before_configuration << name if options[:auto_activate_before_configuration]
      end

      # @api private
      # Load an extension by name, lazily evaluating the block provided to {#register} if necessary.
      # @param [Symbol] name The name of the extension
      # @return [Class<Middleman::Extension>] A {Middleman::Extension} class implementing the extension
      #
      def load(name)
        raise 'Extension name must be a symbol' unless name.is_a?(Symbol)

        unless registered.key?(name)
          raise "Unknown Extension: #{name}. Check the name and make sure you have referenced the extension's gem in your Gemfile."
        end

        extension_class = registered[name]
        if extension_class.is_a?(Proc)
          extension_class = extension_class.call
          registered[name] = extension_class
        end

        unless extension_class.ancestors.include?(::Middleman::Extension)
          raise "Tried to activate old-style extension: #{name}. They are no longer supported."
        end

        # Set the extension's name to whatever it was registered as.
        extension_class.ext_name = name

        extension_class
      end
    end
  end
end
