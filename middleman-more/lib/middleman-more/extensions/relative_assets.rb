# Extension namespace
module Middleman
  module Extensions

    # Relative Assets extension
    module RelativeAssets

      # Setup extension
      class << self

        # Once registered
        def registered(app)
          # Tell compass to use relative assets
          app.compass_config do |config|
            config.relative_assets = true
          end

          # Include instance methods
          app.send :include, InstanceMethods
        end

        alias :included :registered
      end

      # Relative Assets instance method
      module InstanceMethods

        # asset_url override for relative assets
        # @param [String] path
        # @param [String] prefix
        # @return [String]
        def asset_url(path, prefix="")
          path = super(path, prefix)

          if path.include?("//") || !current_resource
            path
          else
            current_dir = Pathname('/' + current_resource.destination_path)
            Pathname(path).relative_path_from(current_dir.dirname).to_s
          end
        end
      end
    end
  end
end
