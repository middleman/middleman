# Extension namespace
module Middleman
  module Extensions

    # The Cache Buster extension
    class CacheBuster < ::Middleman::Extension
      
      # After compass is setup, make it use the registered cache buster
      def compass_config(config)
        config.asset_cache_buster do |path, real_path|
          real_path = real_path.path if real_path.is_a? File
          real_path = real_path.gsub(File.join(app.root, app.build_dir), app.source)
          if File.readable?(real_path)
            File.mtime(real_path).strftime("%s") 
          else
            logger.warn "WARNING: '#{File.basename(path)}' was not found (or cannot be read) in #{File.dirname(real_path)}"
          end
        end
      end
      
      # asset_url override if we're using cache busting
      # @param [String] path
      # @param [String] prefix
      def asset_url(path, prefix="", result)
        if result.include?("://") || !%w(.css .png .jpg .jpeg .svg .svgz .js .gif).include?(File.extname(result))
          result
        else
          if app.respond_to?(:http_images_path) && prefix == app.http_images_path
            prefix = app.images_dir
          end

          real_path_static = File.join(prefix, path)
      
          if app.build?
            real_path_dynamic = File.join(app.build_dir, prefix, path)
            real_path_dynamic = File.expand_path(real_path_dynamic, app.root)
            result << "?" + File.mtime(real_path_dynamic).strftime("%s") if File.readable?(real_path_dynamic)
          elsif resource = app.sitemap.find_resource_by_path(real_path_static)
            if !resource.template?
              result << "?" + File.mtime(resource.source_file).strftime("%s")
            else
              # It's a template, possible with partials. We can't really
              # know when it's updated, so generate fresh cache buster every
              # time during developement
              result << "?" + Time.now.strftime("%s")
            end
          end
      
          result
        end
      end
    end
  end
end
