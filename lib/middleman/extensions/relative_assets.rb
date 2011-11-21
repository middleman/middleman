module Middleman::Extensions
  module RelativeAssets
    class << self
      def registered(app)
        app.compass_config do |config|
          config.relative_assets = true
        end
      
        app.send :include, InstanceMethods
      end
      alias :included :registered
    end
  
    module InstanceMethods
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
          request_path = @request_path.dup
          request_path << index_file if path.match(%r{/$})
          request_path.gsub!(%r{^/}, '')
          parts = request_path.split('/')

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
  
  register :relative_assets, RelativeAssets
end