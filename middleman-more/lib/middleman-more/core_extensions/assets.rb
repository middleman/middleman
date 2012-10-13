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
    
        def assets_paths
          @_assets_paths ||= AssetPaths.new(self)
        end
        
        # Get the URL of an asset given a type/prefix
        #
        # @param [String] path The path (such as "photo.jpg")
        # @param [String] prefix The type prefix (such as "images")
        # @return [String] The fully qualified asset url
        def asset_url(*args)
          assets_paths.asset_url(*args)
        end
      end

      class AssetPaths
        def initialize(app)
          @app = app
          @handlers = Set.new
          
          register_handler do |path, prefix, result|
            # Don't touch assets which already have a full path
            if path.include?("//")
              path
            else # rewrite paths to use their destination path
              path = File.join(prefix, path)
              if resource = @app.sitemap.find_resource_by_path(path)
                resource.url
              else
                File.join(@app.http_prefix, path)
              end
            end
          end
        end
        
        def register_handler(&block)
          @handlers << block if block_given?
        end
        
        # Get the URL of an asset given a type/prefix
        #
        # @param [String] path The path (such as "photo.jpg")
        # @param [String] prefix The type prefix (such as "images")
        # @return [String] The fully qualified asset url
        def asset_url(path, prefix="")
          @handlers.inject("") do |result, handler|
            handler.call(path, prefix, result)
          end
        end
      end
    
      ::Middleman::Extension.add_hooks do
        set_callback :activate, :after, :autoregister_asset_url

        def autoregister_asset_url
          return unless respond_to?(:asset_url)
          app.assets_paths.register_handler(&method(:asset_url))
        end
      end
    end
  end
end
