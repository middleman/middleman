module Compass::SassExtensions::Functions::Urls

  def stylesheet_url(path)
    # Compute the path to the stylesheet, either root relative or stylesheet relative
    # or nil if the http_images_path is not set in the configuration.
    http_stylesheets_path = if relative?
      compute_relative_path(Compass.configuration.css_dir)
    elsif Compass.configuration.http_stylesheets_path
      Compass.configuration.http_stylesheets_path
    else
      Compass.configuration.root_relative(Compass.configuration.css_dir)
    end

    url("#{http_stylesheets_path}/#{path}")
  end

  def image_url(path)
    path = path.value # get to the string value of the literal.
    # Short curcuit if they have provided an absolute url.
    if absolute_path?(path)
      return Sass::Script::String.new("url(#{path})")
    end

    # Compute the path to the image, either root relative or stylesheet relative
    # or nil if the http_images_path is not set in the configuration.
    http_images_path = if relative?
      compute_relative_path(Compass.configuration.images_dir)
    elsif Compass.configuration.http_images_path
      Compass.configuration.http_images_path
    else
      Compass.configuration.root_relative(Compass.configuration.images_dir)
    end

    # Compute the real path to the image on the file stystem if the images_dir is set.
    real_path = if Compass.configuration.images_dir
      File.join(Compass.configuration.project_path, Compass.configuration.images_dir, path)
    end

    # prepend the path to the image if there's one
    if http_images_path
      http_images_path = "#{http_images_path}/" unless http_images_path[-1..-1] == "/"
      path = "#{http_images_path}#{path}"
    end

    # Compute the asset host unless in relative mode.
    asset_host = if !relative? && Compass.configuration.asset_host
      Compass.configuration.asset_host.call(path)
    end

    # Compute and append the cache buster if there is one.
    if buster = compute_cache_buster(path, real_path)
      path += "?#{buster}"
    end

    # prepend the asset host if there is one.
    path = "#{asset_host}#{'/' unless path[0..0] == "/"}#{path}" if asset_host

    url(path)
  end

  # Emits a url, taking off any leading "./"
  def url(url)
    url = url.to_s
    url = url[0..1] == "./" ? url[2..-1] : url
    Sass::Script::String.new("url('#{url}')")
  end

  private

  def relative?
    Compass.configuration.relative_assets?
  end

  def absolute_path?(path)
    path[0..0] == "/" || path[0..3] == "http"
  end

  def compute_relative_path(dir)
    if (target_css_file = options[:css_filename])
      path = File.join(Compass.configuration.project_path, dir)
      Pathname.new(path).relative_path_from(Pathname.new(File.dirname(target_css_file))).to_s
    end
  end

  def compute_cache_buster(path, real_path)
    if Compass.configuration.asset_cache_buster
      args = [path]
      if Compass.configuration.asset_cache_buster.arity > 1
        args << (File.new(real_path) if real_path)
      end
      Compass.configuration.asset_cache_buster.call(*args)
    elsif real_path
      default_cache_buster(path, real_path)
    end
  end

  def default_cache_buster(path, real_path)
    if File.readable?(real_path)
      File.mtime(real_path).strftime("%s") 
    else
      $stderr.puts "WARNING: '#{File.basename(path)}' was not found (or cannot be read) in #{File.dirname(real_path)}"
    end
  end

end
