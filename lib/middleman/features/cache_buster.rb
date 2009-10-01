class Middleman::Base
  helpers do
    alias_method :pre_cache_buster_asset_url, :asset_url
    def asset_url(path, prefix="")
      path = pre_cache_buster_asset_url(path, prefix)
      if path.include?("://")
        path
      else
        real_path = File.join(options.public, path)
        if File.readable?(real_path)
          path << "?" + File.mtime(real_path).strftime("%s")
        else
          $stderr.puts "WARNING: '#{File.basename(path)}' was not found (or cannot be read) in #{File.dirname(real_path)}"
        end
      end
    end
  end
end