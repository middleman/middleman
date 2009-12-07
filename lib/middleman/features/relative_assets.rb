class Middleman::Base  
  after_feature_init do 
    ::Compass.configuration do |config|
      config.relative_assets = Proc.new do
        Middleman::Base.respond_to?(:relative_assets?) && Middleman::Base.relative_assets?
      end
    end
    
    ::Compass.configure_sass_plugin!
  end
end

class << Middleman::Base
  alias_method :pre_relative_asset_url, :asset_url
  def asset_url(path, prefix="", request=nil)
    if !self.respond_to?(:relative_assets?) || !self.relative_assets?
      return pre_relative_asset_url(path, prefix, request)
    end
    
    begin
      prefix = self.images_dir if prefix == self.http_images_path
    rescue
    end
    
    if path.include?("://")
      pre_relative_asset_url(path, prefix, request)
    elsif path[0,1] == "/"
      path
    else
      path = File.join(prefix, path) if prefix.length > 0
      request_path = request.path_info.dup
      request_path << self.index_file if path.match(%r{/$})
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