module Middleman
  class ConfigContext
    # with_layout and page routing
    include Middleman::CoreExtensions::Routing

    attr_reader :app

    # Whitelist methods that can reach out.
    delegate :config, :logger, :activate, :use, :map, :mime_type, :data, :template_extensions, :root, :to => :app

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
  end
end