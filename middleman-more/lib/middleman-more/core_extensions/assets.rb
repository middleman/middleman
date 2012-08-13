module Middleman
  module CoreExtensions

    # Base helper to manipulate asset paths
    module Assets

      # Extension registered
      class << self
        def registered(app)
          # Disable Padrino cache buster
          app.set :asset_stamp, false

          # Include helpers
          app.send :include, InstanceMethod
        end
        alias :included :registered
      end

      # Methods to be mixed-in to Middleman::Application
      module InstanceMethod

        # Get the URL of an asset given a type/prefix
        #
        # @param [String] path The path (such as "photo.jpg")
        # @param [String] prefix The type prefix (such as "images")
        # @return [String] The fully qualified asset url
        def asset_url(path, prefix="")
          # Don't touch assets which already have a full path
          if path.include?("//")
            path
          else # rewrite paths to use their destination path
            path = File.join(prefix, path)
            if resource = sitemap.find_resource_by_path(path)
              resource.url
            else
              File.join(http_prefix, path)
            end
          end
        end
      end
    end
  end
end
