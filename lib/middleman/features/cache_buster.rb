class Middleman::Base  
  after_feature_init do 
    ::Compass.configuration do |config|
      config.asset_cache_buster do |path, real_path|
        real_path = real_path.path if real_path.is_a? File
        real_path = real_path.gsub(File.join(self.root, self.build_dir), self.public)
        if File.readable?(real_path)
          File.mtime(real_path).strftime("%s") 
        else
          $stderr.puts "WARNING: '#{File.basename(path)}' was not found (or cannot be read) in #{File.dirname(real_path)}"
        end
      end
    end
    
    ::Compass.configure_sass_plugin!
  end
end
    
class << Middleman::Base    
  alias_method :pre_cache_buster_asset_url, :asset_url
  def asset_url(path, prefix="", request=nil)
    http_path = pre_cache_buster_asset_url(path, prefix, request)
    
    if http_path.include?("://") || !%w(.css .png .jpg .js .gif).include?(File.extname(http_path))
      http_path
    else
      begin
        prefix = self.images_dir if prefix == self.http_images_path
      rescue
      end
      
      real_path_static  = File.join(self.public, prefix, path)
      
      if File.readable?(real_path_static)
        http_path << "?" + File.mtime(real_path_static).strftime("%s") 
      elsif Middleman::Base.environment == "build"
        real_path_dynamic = File.join(self.root, self.build_dir, prefix, path)
        http_path << "?" + File.mtime(real_path_dynamic).strftime("%s") if File.readable?(real_path_dynamic)
      end
      
      http_path
    end
  end
end