# Extension namespace
module Middleman::Extensions
  
  # The Cache Buster extension
  module CacheBuster
    
    # Setup extension
    class << self
      
      # Once registered
      def registered(app)
        # Add instance methods to context
        app.send :include, InstanceMethods
      
        # After compass is setup, make it use the registered cache buster
        app.compass_config do |config|
          config.asset_cache_buster do |path, real_path|
            real_path = real_path.path if real_path.is_a? File
            real_path = real_path.gsub(File.join(root, build_dir), source)
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
  
    # Cache buster instance methods
    module InstanceMethods
      
      # asset_url override if we're using cache busting
      # @param [String] path
      # @param [String] prefix
      def asset_url(path, prefix="")
        http_path = super

        if http_path.include?("://") || !%w(.css .png .jpg .jpeg .svg .svgz .js .gif).include?(File.extname(http_path))
          http_path
        else
          begin
            prefix = images_dir if prefix == http_images_path
          rescue
          end

          real_path_static = File.join(prefix, path)
        
          if build?
            real_path_dynamic = File.join(build_dir, prefix, path)
            real_path_dynamic = File.expand_path(real_path_dynamic, root)
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
  
  # Register the extension
  # register :cache_buster, CacheBuster
end