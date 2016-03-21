require 'middleman-core/extension'

module Middleman
  # The Extensions module is used to handle global registration and loading of Middleman Extensions.
  #
  # The application-facing extension API ({Middleman::CoreExtensions::Extensions#activate activate}, etc) is in {Middleman::CoreExtensions::Extensions} in
  # `middleman-core/core_extensions/extensions.rb`.
  module Extensions
    @registered = {}
    @auto_activate = {
      # Activate before the Sitemap is instantiated
      before_sitemap: Set.new,

      # Activate the extension before `config.rb` and the `:before_configuration` hook.
      before_configuration: Set.new
    }

    AutoActivation = Struct.new(:name, :modes)

    class << self
      # @api private
      # A hash of all registered extensions. Registered extensions are not necessarily active - this
      # is the set of all extensions that are known to Middleman.
      # @return [Hash{Symbol => Class<Middleman::Extension>, Proc}] A directory of known extensions indexed by the name they were registered under. The value may be a Proc, which can be lazily called to return an extension class.
      attr_reader :registered

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
      # @option options [Boolean] :auto_activate If this is set to a lifecycle event (:before_configuration or :before_sitemap), this extension will be automatically activated at that point.
      #         This is intended for use with built-in Middleman extensions and should not be used by third-party extensions.
      # @yield Instead of passing a module in namespace, you can provide
      #        a block which returns your extension class. This gives
      #        you the ability to require other files only when the
      #        extension is first activated.
      # @return [void]
      def register(name, extension_class=nil, options={}, &block)
        raise 'Extension name must be a symbol' unless name.is_a?(Symbol)
        # If we've already got an extension registered under this name, bail out
        # raise "There is a already an extension registered with the name '#{name}'" if registered.key?(name)

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

        return unless options[:auto_activate]

        descriptor = AutoActivation.new(name, options[:modes] || :all)
        @auto_activate[options[:auto_activate]] << descriptor
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

      # @api private
      # A flattened list of all extensions which are automatically activated
      # @return [Array<Symbol>] A list of extension names which are automatically activated.
      def auto_activated
        @auto_activate.values.map(&:to_a).flatten.map(&:name)
      end

      # @api private
      # Load autoactivatable extensions for the given env.
      # @param [Symbol] group The name of the auto_activation group.
      # @param [Middleman::Application] app An instance of the app.
      def auto_activate(group, app)
        @auto_activate[group].each do |descriptor|
          next unless descriptor[:modes] == :all || descriptor[:modes].include?(app.config[:mode])

          app.extensions.activate descriptor[:name]
        end
      end

      def load_settings(app)
        registered.each do |name, _|
          begin
            ext = load(name)
            unless ext.global_config.all_settings.empty?
              app.config.load_settings(ext.global_config.all_settings)
            end
          rescue LoadError
          end
        end
      end
    end
  end
end
