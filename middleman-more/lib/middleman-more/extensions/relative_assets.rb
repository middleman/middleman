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
          begin
            prefix = images_dir if prefix == http_images_path
          rescue
          end

          if path.include?("://")
            super(path, prefix)
          elsif path[0,1] == "/"
            path
          else
            path = File.join(prefix, path) if prefix.length > 0
            
            request_path = current_path.dup
            request_path << index_file if path.match(%r{/$})

            parts = request_path.gsub(%r{^/}, '').split('/')

            if parts.length > 1
              arry = []
              (parts.length - 1).times { arry << ".." }
              arry << path
              File.join(*arry)
            else
              path
            end
          end
        end
      end
    end
  end
end
