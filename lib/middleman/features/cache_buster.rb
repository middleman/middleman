class Middleman::Features::CacheBuster
  def initialize(app, config)
    Middleman::Assets.register :cache_buster do |path, prefix, request|
      http_path = Middleman::Assets.before(:cache_buster, path, prefix, request)

      if http_path.include?("://") || !%w(.css .png .jpg .js .gif).include?(File.extname(http_path))
        http_path
      else
        begin
          prefix = Middleman::Server.images_dir if prefix == Middleman::Server.http_images_path
        rescue
        end

        real_path_static  = File.join(Middleman::Server.public, prefix, path)

        if File.readable?(real_path_static)
          http_path << "?" + File.mtime(real_path_static).strftime("%s") 
        elsif Middleman::Server.environment == :build
          real_path_dynamic = File.join(Middleman::Server.root, Middleman::Server.build_dir, prefix, path)
          http_path << "?" + File.mtime(real_path_dynamic).strftime("%s") if File.readable?(real_path_dynamic)
        end

        http_path
      end
    end
    
    Middleman::Server.after_feature_init do 
      ::Compass.configuration do |config|
        config.asset_cache_buster do |path, real_path|
          real_path = real_path.path if real_path.is_a? File
          real_path = real_path.gsub(File.join(Middleman::Server.root, Middleman::Server.build_dir), Middleman::Server.public)
          if File.readable?(real_path)
            File.mtime(real_path).strftime("%s") 
          else
            $stderr.puts "WARNING: '#{File.basename(path)}' was not found (or cannot be read) in #{File.dirname(real_path)}"
          end
        end
      end
    end
  end
end

Middleman::Features.register :cache_buster, Middleman::Features::CacheBuster