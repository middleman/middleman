module Middleman
  class ExtensionManager
    extend Forwardable

    def_delegator :@app, :logger
    def_delegators :@activated, :[], :each

    def initialize(app)
      @app = app
      @activated = {}

      ::Middleman::Extensions.load_settings(@app)

      manager = self

      {
        before_sitemap: :before_sitemap,
        initialized: :before_configuration
      }.each do |key, value|
        cb = proc { manager.auto_activate(value) }
        @app.send(key, &cb)
      end

      @app.after_configuration_eval(&method(:activate_all))
    end

    def auto_activate(key)
      ::Middleman::Extensions.auto_activate(key, @app)
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
      begin
        extension = ::Middleman::Extensions.load(ext_name)
      rescue LoadError => e
        logger.debug "== Failed Activation `#{ext_name}` : #{e.message}"
        return
      end

      logger.debug "== Activating: #{ext_name}"

      if extension.supports_multiple_instances?
        @activated[ext_name] ||= {}
        key = "instance_#{@activated[ext_name].keys.length}"
        @activated[ext_name][key] = extension.new(@app, options, &block)
      elsif @activated.key?(ext_name)
        raise "#{ext_name} has already been activated and cannot be re-activated."
      else
        @activated[ext_name] = extension.new(@app, options, &block)
      end
    end

    def activate_all
      logger.debug 'Loaded extensions:'
      @instances = @activated.each_with_object([]) do |(ext_name, ext), sum|
        if ext.is_a?(Hash)
          ext.each do |instance_key, instance|
            logger.debug "== Extension: #{ext_name} #{instance_key}"
            sum << instance
          end
        else
          logger.debug "== Extension: #{ext_name}"
          sum << ext
        end
      end

      @instances.each do |ext|
        ::Middleman::Extension.activated_extension(ext)
      end
    end

    def add_exposed_to_context(context)
      @instances.each do |ext|
        ext.add_exposed_to_context(context)
      end
    end
  end
end
