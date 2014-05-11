require 'middleman-core/extension'

module Middleman
  # The Extensions module is used to handle global registration and loading of Middleman Extensions.
  #
  # The application-facing extension API (activate, etc) is in Middleman::CoreExtensions::Extensions in
  # middleman-core/core_extensions/extensions.rb.
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
        raise "There is already an extension registered with the name '#{name}'" if registered.key?(name.to_sym)

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
end
