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

module Middleman::CoreExtensions::Extensions
  
  class << self
    def included(app)
      # app.set :default_extensions, []
      app.define_hook :after_configuration
      app.define_hook :before_configuration
      app.define_hook :build_config
      app.define_hook :development_config
      
      app.extend ClassMethods
      app.send :include, InstanceMethods
    end
  end

  module ClassMethods
    def configure(env, &block)
      send("#{env}_config", &block)
    end
    
    def extensions
      @extensions ||= []
    end
    
    def register(*new_extensions)
      @extensions ||= []
      @extensions += new_extensions
      new_extensions.each do |extension|
        extend extension
        extension.registered(self) if extension.respond_to?(:registered)
      end
    end
  end
  
  module InstanceMethods
    # This method is available in the project's `config.rb`.
    # It takes a underscore-separated symbol, finds the appropriate
    # feature module and includes it.
    #
    #     activate :lorem
    def activate(feature)
      ext = ::Middleman::Extensions.load(feature.to_sym)
      
      if ext.nil?
        puts "== Unknown Extension: #{feature}"
      elsif ext.is_a?(String)
        puts ext
      else
        puts "== Activating: #{feature}" if logging?
        self.class.register(ext)
      end
    end

    def configure(env, &block)
      self.class.configure(env, &block)
    end
    
    # Load features before starting server
    def initialize
      super
      
      run_hook :before_configuration
    
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
