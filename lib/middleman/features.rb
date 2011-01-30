module Middleman::Features
  autoload :RelativeAssets,      "middleman/features/relative_assets"
  autoload :AssetHost,           "middleman/features/asset_host"
  autoload :CacheBuster,         "middleman/features/cache_buster"
  autoload :DefaultHelpers,      "middleman/features/default_helpers"
  autoload :AutomaticImageSizes, "middleman/features/automatic_image_sizes"
  autoload :UglyHaml,            "middleman/features/ugly_haml"
  autoload :MinifyCss,           "middleman/features/minify_css"
  autoload :MinifyJavascript,    "middleman/features/minify_javascript"
  autoload :Slickmap,            "middleman/features/slickmap"
  autoload :SmushPngs,           "middleman/features/smush_pngs"
  autoload :CodeRay,             "middleman/features/code_ray"
  autoload :Lorem,               "middleman/features/lorem"
  # autoload :LiveReload,          "middleman/features/live_reload"
  
  class << self
    def registered(app)
      app.extend ClassMethods
    end
    alias :included :registered
  end
  
  module ClassMethods
    def activate(feature_name)
      mod_name = feature_name.to_s.camelize
      if Middleman::Features.const_defined?(mod_name)
        register Middleman::Features.const_get(mod_name)
      end
    end
    
    def enable(feature_name)
      $stderr.puts "Warning: Feature activation has been renamed from enable to activate"
      activate(feature_name)
      super(feature_name)
    end
  end
end
