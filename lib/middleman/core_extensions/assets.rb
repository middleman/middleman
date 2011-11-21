module Middleman::CoreExtensions::Assets
  class << self
    def registered(app)
      # Disable Padrino cache buster
      app.set :asset_stamp, false
      
      app.send :include, InstanceMethod
    end
    alias :included :registered
  end
  
  module InstanceMethod
    def asset_url(path, prefix="")
      path.include?("://") ? path : File.join(http_prefix, prefix, path)
    end
  end
end