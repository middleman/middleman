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

module Middleman::Features

  # RelativeAssets allow any asset path in dynamic templates to be either
  # relative to the root of the project or use an absolute URL.
  autoload :RelativeAssets,      "middleman/features/relative_assets"
  
  # AssetHost allows you to setup multiple domains to host your static assets.
  # Calls to asset paths in dynamic templates will then rotate through each of
  # the asset servers to better spread the load.
  autoload :AssetHost,           "middleman/features/asset_host"
  
  # CacheBuster adds a query string to assets in dynamic templates to avoid
  # browser caches failing to update to your new content.
  autoload :CacheBuster,         "middleman/features/cache_buster"
  
  # DefaultHelpers are the built-in dynamic template helpers.
  autoload :DefaultHelpers,      "middleman/features/default_helpers"
  
  # AutomaticImageSizes inspects the images used in your dynamic templates and
  # automatically adds width and height attributes to their HTML elements.
  autoload :AutomaticImageSizes, "middleman/features/automatic_image_sizes"
  
  # UglyHaml enables the non-indented output format from Haml templates. Useful
  # for somewhat obfuscating the output and hiding the fact that you're using Haml.
  autoload :UglyHaml,            "middleman/features/ugly_haml"
  
  # MinifyCss uses the YUI compressor to shrink CSS files
  autoload :MinifyCss,           "middleman/features/minify_css"
  
  # MinifyJavascript uses the YUI compressor to shrink JS files
  autoload :MinifyJavascript,    "middleman/features/minify_javascript"
  
  # Slickmap (http://astuteo.com/slickmap/) is a beautiful sitemap tool which 
  # will attempt to generate a `sitemap.html` file from your project.
  autoload :Slickmap,            "middleman/features/slickmap"
  
  # SmushPngs uses Yahoo's Smush.it API to compresses PNGs and JPGs. Often times
  # the service can decrease the size of Photoshop-exported images by 30-50%
  autoload :SmushPngs,           "middleman/features/smush_pngs"
  
  # CodeRay is a syntax highlighter.
  autoload :CodeRay,             "middleman/features/code_ray"
  
  # Lorem provides a handful of helpful prototyping methods to generate words,
  # paragraphs, fake images, names and email addresses.
  autoload :Lorem,               "middleman/features/lorem"
  
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
    def activate(feature_name)
      feature_name = feature_name.to_s if feature_name.class == Symbol
      feature_name = Middleman::Features.const_get(feature_name.camelize) if feature_name.class == String if Middleman::Features.const_defined?(mod_name)
    
      register feature_name
    end
    
    # Deprecated API. Please use `activate` instead.
    def enable(feature_name)
      $stderr.puts "Warning: Feature activation has been renamed from enable to activate"
      activate(feature_name)
      super(feature_name)
    end
  end
end
