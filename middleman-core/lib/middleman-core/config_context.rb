require 'rack/mime'

module Middleman
  class ConfigContext
    extend Forwardable

    attr_reader :app

    # Whitelist methods that can reach out.
    def_delegators :@app, :config, :logger, :use, :map, :mime_type, :data, :files, :root, :build?, :server?, :environment?
    def_delegator :"@app.extensions", :activate

    def initialize(app, template_context_class)
      @app = app
      @template_context_class = template_context_class

      @ready_callbacks = []
      @after_build_callbacks = []
      @after_configuration_callbacks = []
      @configure_callbacks = {}
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

    def ready(&block)
      @ready_callbacks << block
    end

    def execute_ready_callbacks
      @ready_callbacks.each do |b|
        instance_exec(&b)
      end
    end

    def after_build(&block)
      @after_build_callbacks << block
    end

    def execute_after_build_callbacks(*args)
      @after_build_callbacks.each do |b|
        instance_exec(*args, &b)
      end
    end

    def after_configuration(&block)
      @after_configuration_callbacks << block
    end

    def execute_after_configuration_callbacks
      @after_configuration_callbacks.each do |b|
        instance_exec(&b)
      end
    end

    def configure(key, &block)
      @configure_callbacks[key] ||= []
      @configure_callbacks[key] << block
    end

    def execute_configure_callbacks(key)
      @configure_callbacks[key] ||= []
      @configure_callbacks[key].each do |b|
        instance_exec(&b)
      end
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
