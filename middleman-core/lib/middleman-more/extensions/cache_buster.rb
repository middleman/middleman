# The Cache Buster extension
class Middleman::Extensions::CacheBuster < ::Middleman::Extension
  def initialize(app, options_hash={}, &block)
    super

    # After compass is setup, make it use the registered cache buster
    app.compass_config do |config|
      config.asset_cache_buster do |path, real_path|
        real_path = real_path.path if real_path.is_a? File
        real_path = real_path.gsub(File.join(root, build_dir), source)
        if File.readable?(real_path)
          File.mtime(real_path).strftime('%s')
        else
          logger.warn "WARNING: '#{File.basename(path)}' was not found (or cannot be read) in #{File.dirname(real_path)}"
        end
      end
    end if app.respond_to?(:compass_config)
  end

  helpers do
    # asset_url override if we're using cache busting
    # @param [String] path
    # @param [String] prefix
    def asset_url(path, prefix='')
      http_path = super

      if http_path.include?('://') || !%w(.css .png .jpg .jpeg .svg .svgz .webp .js .gif).include?(File.extname(http_path))
        http_path
      else
        if respond_to?(:http_images_path) && prefix == http_images_path
          prefix = images_dir
        end

        real_path_static = File.join(prefix, path)

        if build?
          real_path_dynamic = File.join(build_dir, prefix, path)
          real_path_dynamic = File.expand_path(real_path_dynamic, root)
          http_path << '?' + File.mtime(real_path_dynamic).strftime('%s') if File.readable?(real_path_dynamic)
        elsif resource = sitemap.find_resource_by_path(real_path_static)
          if !resource.template?
            http_path << '?' + File.mtime(resource.source_file).strftime('%s')
          else
            # It's a template, possible with partials. We can't really
            # know when it's updated, so generate fresh cache buster every
            # time during developement
            http_path << '?' + Time.now.strftime('%s')
          end
        end

        http_path
      end
    end
  end
end
