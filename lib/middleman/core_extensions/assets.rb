# Base helper to manipulate asset paths
module Middleman::CoreExtensions::Assets
  
  # Extension registered
  class << self
    # @private
    def registered(app)
      # Disable Padrino cache buster
      app.set :asset_stamp, false
      
      # Include helpers
      app.send :include, InstanceMethod
    end
    alias :included :registered
  end
  
  # Methods to be mixed-in to Middleman::Base
  module InstanceMethod
    
    # Get the URL of an asset given a type/prefix
    #
    # @param [String] path The path (such as "photo.jpg")
    # @param [String] prefix The type prefix (such as "images")
    def asset_url(path, prefix="")
      # Don't touch assets which already have a full path
      path.include?("://") ? path : File.join(http_prefix, prefix, path)
    end
  end
end