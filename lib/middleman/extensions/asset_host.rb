module Middleman::Extensions
  module AssetHost
    class << self
      def registered(app)
        app.set :asset_host, false
      
        app.compass_config do |config|
          if asset_host.is_a?(Proc)
            config.asset_host(&asset_host)
          end
        end
      
        app.send :include, InstanceMethods
      end
      alias :included :registered
    end
  
    module InstanceMethods
      def asset_url(path, prefix="")
        original_output = super

        valid_extensions = %w(.png .gif .jpg .jpeg .svg .svgz .js .css)

        asset_prefix = if asset_host.is_a?(Proc)
          asset_host.call(original_output)
        elsif asset_host.is_a?(String)
          asset_host
        end

        File.join(asset_prefix, original_output)
      end
    end
  end
end
