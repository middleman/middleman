module Middleman::Features::CacheBuster
  class << self
    def registered(app)
      app.send :include, InstanceMethods
      
      app.compass_config do |config|
        config.asset_cache_buster do |path, real_path|
          real_path = real_path.path if real_path.is_a? File
          real_path = real_path.gsub(File.join(self.root, self.build_dir), self.views)
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
  
  module InstanceMethods
    def asset_url(path, prefix="")
      http_path = super

      if http_path.include?("://") || !%w(.css .png .jpg .js .gif).include?(File.extname(http_path))
        http_path
      else
        begin
          prefix = self.images_dir if prefix == self.http_images_path
        rescue
        end

        real_path_static = File.join(prefix, path)
        
        if self.build?
          real_path_dynamic = File.join(self.build_dir, prefix, path)
          real_path_dynamic = File.expand_path(real_path_dynamic, self.root)
          http_path << "?" + File.mtime(real_path_dynamic).strftime("%s") if File.readable?(real_path_dynamic)
        elsif sitemap.exists?(real_path_static)
          page = sitemap.page(real_path_static)
          if !page.template?
            http_path << "?" + File.mtime(result[0]).strftime("%s")
          else
            # It's a template, possible with partials. We can't really know when
            # it's updated, so generate fresh cache buster every time durin
            # developement
            http_path << "?" + Time.now.strftime("%s")
          end
        end
        
        http_path
      end
    end
  end
end