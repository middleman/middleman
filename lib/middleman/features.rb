module Middleman
  module Features
    # Top-level method to register a new feature
    @@features = {}
    def self.register(feature_name, feature_class=nil, options={})
      @@features[feature_name] = feature_class
    
      # Default to disabled, unless the class asks to auto-enable
      activate_method = (options.has_key?(:auto_enable) && options[:auto_enable]) ? :enable : :disable
      Middleman::Server.send(activate_method, feature_name)
    end
    
    # Initialize a feature
    def self.run(feature_name, feature_config, scope)
      feature_class = @@features[feature_name]
      feature_class.new(scope, feature_config) unless feature_class.nil?
    end

    # Get a list of all features
    def self.all
      @@features
    end

  end
end

# livereload
%w(default_helpers
   asset_host 
   automatic_image_sizes
   cache_buster
   minify_css
   minify_javascript
   relative_assets
   slickmap
   smush_pngs
   ugly_haml).each do |feature| 
     
  require File.join("middleman/features", feature)

end