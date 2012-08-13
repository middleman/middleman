# Extensions namespace
module Middleman
  module Extensions

    # Asset Host module
    module AssetHost

      # Setup extension
      class << self

        # Once registered
        def registered(app)
          # Default to no host
          app.set :asset_host, false

          # Include methods
          app.send :include, InstanceMethods
        end

        alias :included :registered
      end

      # Asset Host Instance Methods
      module InstanceMethods

        # Override default asset url helper to include asset hosts
        #
        # @param [String] path
        # @param [String] prefix
        # @return [String]
        def asset_url(path, prefix="")
          original_output = super
          return original_output unless asset_host

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
end
