class << Middleman::Base
  alias_method :pre_cache_buster_asset_url, :asset_url
  def asset_url(path, prefix="")
    http_path = pre_cache_buster_asset_url(path, prefix)
    if http_path.include?("://") || !%w(.css .png .jpg .js .gif).include?(File.extname(http_path))
      http_path
    else
      real_path = File.join(self.environment == "build" ? self.build_dir : self.public, prefix, path)
      http_path << "?" + File.mtime(real_path).strftime("%s") if File.readable?(real_path)        
      http_path
    end
  end
end