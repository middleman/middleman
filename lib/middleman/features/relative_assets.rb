module Middleman::Features::RelativeAssets
  class << self
    def registered(app)
      app.compass_config do |config|
        config.relative_assets = true
      end

      app.register_asset_handler :relative_assets do |path, prefix, request|
        begin
          prefix = app.images_dir if prefix == app.http_images_path
        rescue
        end

        if path.include?("://")
          app.before_asset_handler(:relative_assets, path, prefix, request)
        elsif path[0,1] == "/"
          path
        else
          path = File.join(prefix, path) if prefix.length > 0
          request_path = request.path_info.dup
          request_path << app.index_file if path.match(%r{/$})
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
    alias :included :registered
  end
end