module Middleman::Features::AssetHost
  class << self
    def registered(app)
      app.set :asset_host, nil
      
      app.compass_config do |config|
        if self.asset_host.is_a?(Proc)
          config.asset_host(&self.asset_host)
        end
      end
      
      app.send :include, InstanceMethods
    end
    alias :included :registered
  end
  
  module InstanceMethods
    def asset_url(path, prefix="")
      original_output = super

      valid_extensions = %w(.png .gif .jpg .jpeg .js .css)

      asset_prefix = if self.asset_host.is_a?(Proc)
        self.asset_host.call(original_output)
      elsif self.asset_host.is_a?(String)
        self.asset_host
      end

      File.join(asset_prefix, original_output)
    end
  end
end