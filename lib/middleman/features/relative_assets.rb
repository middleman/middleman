class Middleman::Features::RelativeAssets
  def initialize(app, config)
    ::Compass.configuration.relative_assets = true
  
    Middleman::Assets.register :relative_assets do |path, prefix, request|
      begin
        prefix = Middleman::Server.images_dir if prefix == Middleman::Server.http_images_path
      rescue
      end
    
      if path.include?("://")
        Middleman::Assets.before(:relative_assets, path, prefix, request)
      elsif path[0,1] == "/"
        path
      else
        path = File.join(prefix, path) if prefix.length > 0
        request_path = request.path_info.dup
        request_path << Middleman::Server.index_file if path.match(%r{/$})
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

Middleman::Features.register :relative_assets, Middleman::Features::RelativeAssets
