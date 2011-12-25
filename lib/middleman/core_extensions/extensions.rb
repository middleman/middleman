# Middleman provides an extension API which allows you to hook into the
# lifecycle of a page request, or static build, and manipulate the output.
# Internal to Middleman, these extensions are called "features," but we use
# the exact same API as is made available to the public.
#
# A Middleman extension looks like this:
#
#     module MyExtension
#       class << self
#         def registered(app)
#           # My Code
#         end
#       end
#     end
#
# In your `config.rb`, you must load your extension (if it is not defined in
# that file) and call `activate`.
#
#     require "my_extension"
#     activate MyExtension
#
# This will call the `registered` method in your extension and provide you
# with the `app` parameter which is a Middleman::Base context. From here
# you can choose to respond to requests for certain paths or simply attach
# Rack middleware to the stack.
#
# The built-in features cover a wide range of functions. Some provide helper
# methods to use in your views. Some modify the output on-the-fly. And some
# apply computationally-intensive changes to your final build files.

# Using for version parsing
require "rubygems"

# Namespace extensions module
module Middleman::CoreExtensions::Extensions
  
  # Register extension
  class << self
    # @private
    def included(app)
      # app.set :default_extensions, []
      app.define_hook :after_configuration
      app.define_hook :before_configuration
      app.define_hook :build_config
      app.define_hook :development_config
      
      app.extend ClassMethods
      app.send :include, InstanceMethods
      app.delegate :configure, :to => :"self.class"
    end
  end

  # Class methods
  module ClassMethods
    # Add a callback to run in a specific environment
    #
    # @param [String, Symbol] env The environment to run in
    # @return [void]
    def configure(env, &block)
      send("#{env}_config", &block)
    end
    
    # Alias `extensions` to access registered extensions
    #
    # @return [Array<Module]
    def extensions
      @extensions ||= []
    end
    
    # Register a new extension
    # 
    # @param [Array<Module>] new_extensions Extension modules to register
    # @return [Array<Module]
    def register(extension, options={}, &block)
      @extensions ||= []
      @extensions += [extension]
      
      extend extension
      if extension.respond_to?(:registered)
        if extension.method(:registered).arity === 1
          extension.registered(self, &block)
        else
          extension.registered(self, options, &block)
        end
      end
    end
  end
  
  # Instance methods
  module InstanceMethods
    # This method is available in the project's `config.rb`.
    # It takes a underscore-separated symbol, finds the appropriate
    # feature module and includes it.
    #
    #     activate :lorem
    #
    # @param [Symbol, Module] ext Which extension to activate
    # @return [void]
    def activate(ext, options={}, &block)
      if !ext.is_a?(Module)
        ext = ::Middleman::Extensions.load(ext.to_sym)
      end
      
      if ext.nil?
        puts "== Unknown Extension: #{feature}"
      elsif ext.is_a?(String)
        puts ext
      else
        puts "== Activating: #{feature}" if logging?
        self.class.register(ext, options, &block)
      end
    end
    
    # Load features before starting server
    def initialize
      super
      
      self.class.inst = self
      run_hook :before_configuration
    
      # Search the root of the project for required files
      $LOAD_PATH.unshift(root)
      
      # Check for and evaluate local configuration
      local_config = File.join(root, "config.rb")
      if File.exists? local_config
        puts "== Reading:  Local config" if logging?
        instance_eval File.read(local_config)
      end
      
      run_hook :build_config if build?
      run_hook :development_config if development?
      
      run_hook :after_configuration
      
      # Add in defaults
      default_extensions.each do |ext|
        activate ext
      end
      
      if logging?
        self.class.extensions.each do |ext|
          puts "== Extension: #{ext}"
        end
      end
    end
  end
end
