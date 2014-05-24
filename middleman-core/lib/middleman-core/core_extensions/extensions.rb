module Middleman
  module CoreExtensions
    # The Extensions core module provides basic configurability to Middleman projects:
    #
    # * It loads and evaluates `config.rb`.
    # * It defines lifecycle hooks for extensions and `config.rb` to use.
    # * It provides the {#activate} method for use in `config.rb`.
    module Extensions
      def self.included(app)
        app.define_hook :initialized
        app.define_hook :instance_available
        app.define_hook :after_configuration
        app.define_hook :before_configuration
        app.define_hook :build_config
        app.define_hook :development_config

        app.extend ClassMethods
        app.delegate :configure, to: :"self.class"
      end

      module ClassMethods
        # Register a block to run only in a specific environment.
        #
        # @example
        #    # Only minify when building
        #    configure :build do
        #      activate :minify_javascript
        #    end
        #
        # @param [String, Symbol] env The environment to run in (:build, :development)
        # @return [void]
        def configure(env, &block)
          send("#{env}_config", &block)
        end
      end

      # Activate an extension, optionally passing in options.
      # This method is typically used from a project's `config.rb`.
      #
      # @example Activate an extension with no options
      #     activate :lorem
      #
      # @example Activate an extension, with options
      #     activate :minify_javascript, inline: true
      #
      # @example Use a block to configure extension options
      #     activate :minify_javascript do |opts|
      #       opts.ignore += ['*-test.js']
      #     end
      #
      # @param [Symbol] ext_name The name of thed extension to activate
      # @param [Hash] options Options to pass to the extension
      # @yield [Middleman::Configuration::ConfigurationManager] Extension options that can be modified before the extension is initialized.
      # @return [void]
      def activate(ext_name, options={}, &block)
        extension = ::Middleman::Extensions.load(ext_name)
        logger.debug "== Activating: #{ext_name}"

        if extension.supports_multiple_instances?
          extensions[ext_name] ||= {}
          key = "instance_#{extensions[ext_name].keys.length}"
          extensions[ext_name][key] = extension.new(self.class, options, &block)
        elsif extensions.key?(ext_name)
          raise "#{ext_name} has already been activated and cannot be re-activated."
        else
          extensions[ext_name] = extension.new(self.class, options, &block)
        end
      end

      # A hash of all activated extensions, indexed by their name. If an extension supports multiple
      # instances, it will be stored as a hash of instances instead of just the instance.
      #
      # @return [Hash{Symbol => Middleman::Extension, Hash{String => Middleman::Extension}}]
      def extensions
        @extensions ||= {}
      end

      # Override application initialization to load `config.rb` and to call lifecycle hooks.
      def initialize(&block)
        super

        self.class.inst = self

        # Search the root of the project for required files
        $LOAD_PATH.unshift(root) unless $LOAD_PATH.include?(root)

        ::Middleman::Extension.clear_after_extension_callbacks

        ::Middleman::Extensions.auto_activate_before_configuration.each do |ext_name|
          activate ext_name
        end

        if ENV['AUTOLOAD_SPROCKETS'] != 'false'
          begin
            require 'middleman-sprockets'
            activate :sprockets
          rescue LoadError
            # It's OK if somebody is using middleman-core without middleman-sprockets
          end
        end

        # Evaluate a passed block if given
        config_context.instance_exec(&block) if block_given?

        run_hook :initialized

        run_hook :before_configuration

        # Check for and evaluate local configuration in `config.rb`
        local_config = File.join(root, 'config.rb')
        if File.exist? local_config
          logger.debug '== Reading:  Local config'
          config_context.instance_eval File.read(local_config), local_config, 1
        end

        if build?
          run_hook :build_config
          config_context.execute_configure_callbacks(:build)
        end

        if development?
          run_hook :development_config
          config_context.execute_configure_callbacks(:development)
        end

        run_hook :instance_available

        # This is for making the tests work - since the tests
        # don't completely reload middleman, I18n.load_path can get
        # polluted with paths from other test app directories that don't
        # exist anymore.
        if ENV['TEST']
          ::I18n.load_path.delete_if { |path| path =~ %r{tmp/aruba} }
          ::I18n.reload!
        end

        run_hook :after_configuration
        config_context.execute_after_configuration_callbacks

        extension_instances = []
        logger.debug 'Loaded extensions:'
        extensions.each do |ext_name, ext|
          if ext.is_a?(Hash)
            ext.each do |instance_key, instance|
              logger.debug "== Extension: #{ext_name} #{instance_key}"
              extension_instances << instance
            end
          else
            logger.debug "== Extension: #{ext_name}"
            extension_instances << ext
          end
        end

        extension_instances.each do |ext|
          # Forward Extension helpers to TemplateContext
          Array(ext.class.defined_helpers).each do |m|
            @template_context_class.send(:include, m)
          end

          ::Middleman::Extension.activated_extension(ext)
        end
      end
    end
  end
end
