module Middleman::Features::CacheBuster
  class << self
    def registered(app)
      app.register_asset_handler :cache_buster do |path, prefix, request|
        http_path = app.before_asset_handler(:cache_buster, path, prefix, request)

        if http_path.include?("://") || !%w(.css .png .jpg .js .gif).include?(File.extname(http_path))
          http_path
        else
          begin
            prefix = app.images_dir if prefix == app.http_images_path
          rescue
          end

          real_path_static  = File.join(app.views, prefix, path)

          if File.readable?(real_path_static)
            http_path << "?" + File.mtime(real_path_static).strftime("%s") 
          elsif app.build?
            real_path_dynamic = File.join(app.root, app.build_dir, prefix, path)
            http_path << "?" + File.mtime(real_path_dynamic).strftime("%s") if File.readable?(real_path_dynamic)
          end

          http_path
        end
      end

      app.compass_config do |config|
        config.asset_cache_buster do |path, real_path|
          real_path = real_path.path if real_path.is_a? File
          real_path = real_path.gsub(File.join(app.root, app.build_dir), app.views)
          if File.readable?(real_path)
            File.mtime(real_path).strftime("%s") 
          else
            $stderr.puts "WARNING: '#{File.basename(path)}' was not found (or cannot be read) in #{File.dirname(real_path)}"
          end
        end
      end
    end
    alias :included :registered
  end
end