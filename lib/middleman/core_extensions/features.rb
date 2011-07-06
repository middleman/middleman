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
# with the `app` parameter which is a Middleman::Server context. From here
# you can choose to respond to requests for certain paths or simply attach
# Rack middleware to the stack.
#
# The built-in features cover a wide range of functions. Some provide helper
# methods to use in your views. Some modify the output on-the-fly. And some
# apply computationally-intensive changes to your final build files.

module Middleman::CoreExtensions::Features
  
  # The Feature API is itself a Feature. Mind blowing!
  class << self
    def registered(app)
      app.extend ClassMethods
    end
    alias :included :registered
  end

  module ClassMethods
    # This method is available in the project's `config.rb`.
    # It takes a underscore-separated symbol, finds the appropriate
    # feature module and includes it.
    #
    #     activate :lorem
    #
    # Alternatively, you can pass in a Middleman feature module directly.
    #
    #     activate MyFeatureModule
    def activate(feature)
      feature = feature.to_s if feature.is_a? Symbol

      if feature.is_a? String
        feature = feature.camelize
        feature = Middleman::Features.const_get(feature)
      end

      register feature
    end

    # Deprecated API. Please use `activate` instead.
    def enable(feature_name)
      $stderr.puts "Warning: Feature activation has been renamed from enable to activate"
      activate(feature_name)
      super(feature_name)
    end
    
    # Add a block/proc to be run after features have been setup
    def after_feature_init(&block)
      @run_after_features ||= []
      @run_after_features << block
    end
    
    # Load features before starting server
    def new
      # Check for and evaluate local configuration
      local_config = File.join(self.root, "config.rb")
      if File.exists? local_config
        $stderr.puts "== Reading:  Local config" if logging?
        Middleman::Server.class_eval File.read(local_config)
        set :app_file, File.expand_path(local_config)
      end
      
      # Add in defaults
      $stderr.puts default_extensions
      default_extensions.each do |ext|
        activate ext
      end
      
      @run_after_features.each { |block| class_eval(&block) }
  
      super
    end
  end
end
