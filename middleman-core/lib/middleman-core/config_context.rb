require 'rack/mime'
require 'middleman-core/callback_manager'

module Middleman
  class ConfigContext
    extend Forwardable

    attr_reader :app

    # Whitelist methods that can reach out.
    def_delegators :@app, :config, :logger, :use, :map, :mime_type, :files, :root, :build?, :server?, :environment?, :extensions
    def_delegator :"@app.extensions", :activate

    def initialize(app, template_context_class)
      @app = app
      @template_context_class = template_context_class

      @callbacks = ::Middleman::CallbackManager.new
      @callbacks.install_methods!(self, [:before_build, :after_build, :configure, :after_configuration, :ready])

      # Trigger internal callbacks when app level are executed.
      app.subscribe_to_callbacks(&method(:execute_callbacks))
    end

    def include(mod)
      extend(mod)
    end

    def helpers(*helper_modules, &block)
      helper_modules ||= []

      if block_given?
        block_module = Module.new
        block_module.module_eval(&block)
        helper_modules << block_module
      end

      helper_modules.each do |mod|
        @template_context_class.send :include, mod
      end
    end

    def include_environment(name)
      path = File.dirname(__FILE__)
      other_config = File.join(path, name.to_s)

      return unless File.exist? other_config

      instance_eval File.read(other_config), other_config, 1
    end

    def set(key, default=nil, &block)
      config.define_setting(key, default) unless config.defines_setting?(key)
      @app.config[key] = block_given? ? block : default
    end

    # Add a new mime-type for a specific extension
    #
    # @param [Symbol] type File extension
    # @param [String] value Mime type
    # @return [void]
    def mime_type(type, value)
      type = ".#{type}" unless type.to_s[0] == '.'
      ::Rack::Mime::MIME_TYPES[type] = value
    end
  end
end
