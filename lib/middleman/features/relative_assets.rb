class Middleman::Base
  if compass?
    configure do
      ::Compass.configuration do |config|
        config.relative_assets = true
      end
    end
  end
end

class << Middleman::Base
  alias_method :pre_relative_asset_url, :asset_url
  def asset_url(path, prefix="")
    path = pre_relative_asset_url(path, prefix)
    if path.include?("://")
      path
    else
      path = path[1,path.length-1] if path[0,1] == '/'
      request_path = request.path_info.dup
      request_path << options.index_file if path.match(%r{/$})
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