::Compass.configuration do |config|
  config.relative_assets = true
end

class << Middleman::Base
  alias_method :pre_relative_asset_url, :asset_url
  def asset_url(path, prefix="", request=nil)
    begin
      prefix = self.images_dir if prefix == self.http_images_path
    rescue
    end
    
    path = pre_relative_asset_url(path, prefix, request)
    if path.include?("://")
      path
    else
      path = path[1,path.length-1] if path[0,1] == '/'
      request_path = request.path_info.dup
      request_path << self.class.index_file if path.match(%r{/$})
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