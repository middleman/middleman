module Compass::Exec::ProjectOptionsParser
  def set_options(opts)
    super
    set_project_options(opts)
  end
  def set_project_options(opts)
    opts.on('-c', '--config CONFIG_FILE', 'Specify the location of the configuration file explicitly.') do |configuration_file|
      self.options[:configuration_file] = configuration_file
    end

    opts.on('--app APP', 'Tell compass what kind of application it is integrating with. E.g. rails') do |project_type|
      self.options[:project_type] = project_type.to_sym
    end

    opts.on('--sass-dir SRC_DIR', "The source directory where you keep your sass stylesheets.") do |sass_dir|
      self.options[:sass_dir] = sass_dir
    end

    opts.on('--css-dir CSS_DIR', "The target directory where you keep your css stylesheets.") do |css_dir|
      self.options[:css_dir] = css_dir
    end

    opts.on('--images-dir IMAGES_DIR', "The directory where you keep your images.") do |images_dir|
      self.options[:images_dir] = images_dir
    end

    opts.on('--javascripts-dir JS_DIR', "The directory where you keep your javascripts.") do |javascripts_dir|
      self.options[:javascripts_dir] = javascripts_dir
    end

    opts.on('-e ENV', '--environment ENV', [:development, :production], 'Use sensible defaults for your current environment.',
            '  One of: development, production (default)') do |env|
      self.options[:environment] = env
            end

    opts.on('-s STYLE', '--output-style STYLE', [:nested, :expanded, :compact, :compressed], 'Select a CSS output mode.',
            '  One of: nested, expanded, compact, compressed') do |style|
      self.options[:output_style] = style
            end

    opts.on('--relative-assets', :NONE, 'Make compass asset helpers generate relative urls to assets.') do
      self.options[:relative_assets] = true
    end
  end

end
