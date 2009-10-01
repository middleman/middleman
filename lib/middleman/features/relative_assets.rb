class Middleman::Base
  if compass?
    configure do
      ::Compass.configuration do |config|
        config.relative_assets = true
      end
    end
  end
  
  helpers do
    alias_method :pre_relative_asset_url, :asset_url
    def asset_url(path, prefix="")
      path = pre_relative_asset_url(path, prefix)
      if path.include?("://")
        path
      else
        request_path = request.path_info.dup
        request_path << self.index_file if path.match(%r{/$})
        request_path.gsub!(%r{^/}, '')
        parts = request_path.split('/')
      
        if parts.length > 1
          "../" * (parts.length - 1) + path
        else
          path
        end
      end
    end
  end
end