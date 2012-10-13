# Extensions namespace
module Middleman
  module Extensions

    # Asset Host module
    class AssetHost < ::Middleman::Extension
      config_options :host => false
      
      # Override default asset url helper to include asset hosts
      #
      # @param [String] path
      # @param [String] prefix
      # @return [String]
      def asset_url(path, prefix, result)
        host = options[:host]

        # TODO: Deprecation warning for set :asset_host
        return result unless host

        asset_prefix = if host.is_a?(Proc)
          host.call(result)
        elsif host.is_a?(String)
          host
        end
      
        File.join(asset_prefix, result)
      end
    end
  end
end
