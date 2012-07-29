# Extension namespace
module Middleman
  module Extensions

    # Relative Assets extension
    class RelativeAssets < ::Middleman::Extension
      def compass_config(config)
        config.relative_assets = true
      end
      
      # asset_url override for relative assets
      # @param [String] path
      # @param [String] prefix
      # @return [String]
      def asset_url(path, prefix, result)
        if result.include?("//")
          result
        else
          current_dir = Pathname('/' + app.current_resource.destination_path).dirname
          Pathname(result).relative_path_from(current_dir)
        end
      end
    end
    
  end
end
