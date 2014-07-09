class Middleman::CoreExtensions::Internationalization < ::Middleman::Extension
  option :no_fallbacks, false, 'Disable I18n fallbacks'
  option :langs, nil, 'List of langs, will autodiscover by default'
  option :lang_map, {}, 'Language shortname map'
  option :path, '/:locale/', 'URL prefix path'
  option :templates_dir, 'localizable', 'Location of templates to be localized'
  option :mount_at_root, nil, 'Mount a specific language at the root of the site'
  option :data, 'locales', 'The directory holding your locale configurations'

  def_delegator :@app, :logger

  def after_configuration
    # See https://github.com/svenfuchs/i18n/wiki/Fallbacks
    unless options[:no_fallbacks]
      require 'i18n/backend/fallbacks'
      ::I18n::Backend::Simple.send(:include, ::I18n::Backend::Fallbacks)
    end

    app.config.define_setting :locales_dir, 'locales', 'The directory holding your locale configurations'

    file_watcher.reload_path(app.config[:locales_dir] || options[:data])

    @locales_glob = File.join(app.config[:locales_dir] || options[:data], '**', '*.{rb,yml,yaml}')
    @locales_regex = convert_glob_to_regex(@locales_glob)

    @maps = {}
    @mount_at_root = options[:mount_at_root].nil? ? langs.first : options[:mount_at_root]

    configure_i18n

    logger.info "== Locales: #{langs.join(', ')} (Default #{@mount_at_root})"

    # Don't output localizable files
    app.ignore File.join(options[:templates_dir], '**')

    file_watcher.changed(&method(:on_file_changed))
    file_watcher.deleted(&method(:on_file_changed))
  end

  helpers do
    def t(*args)
      ::I18n.t(*args)
    end
  end

  Contract None => ArrayOf[Symbol]
  def langs
    @langs ||= known_languages
  end

  # Update the main sitemap resource list
  # @return Array<Middleman::Sitemap::Resource>
  Contract ResourceList => ResourceList
  def manipulate_resource_list(resources)
    new_resources = []

    resources.each do |resource|
      # If it uses file extension localization
      if parse_locale_extension(resource.path)
        result = parse_locale_extension(resource.path)
        ext_lang, path, page_id = result
        new_resources << build_resource(path, resource.path, page_id, ext_lang)
      # If it's a "localizable template"
      elsif File.fnmatch?(File.join(options[:templates_dir], '**'), resource.path)
        page_id = File.basename(resource.path, File.extname(resource.path))
        langs.each do |lang|
          # Remove folder name
          path = resource.path.sub(options[:templates_dir], '')
          new_resources << build_resource(path, resource.path, page_id, lang)
        end
      end

      # This is for backwards compatibility with the old provides_metadata-based code
      # that used to be in this extension, but I don't know how much sense it makes.
      next if resource.options[:lang]

      resource.add_metadata options: { lang: @mount_at_root }, locals: { lang: @mount_at_root }
    end

    resources + new_resources
  end

  private

  def on_file_changed(file)
    return unless @locales_regex =~ file

    @_langs = nil # Clear langs cache
    ::I18n.reload!
  end

  Contract String => Regexp
  def convert_glob_to_regex(glob)
    # File.fnmatch doesn't support brackets: {rb,yml,yaml}
    regex = glob.sub(/\./, '\.').sub(File.join('**', '*'), '.*').sub(/\//, '\/').sub('{rb,yml,yaml}', '(rb|ya?ml)')
    %r{^#{regex}}
  end

  def configure_i18n
    ::I18n.load_path += Dir[File.join(app.root, @locales_glob)]
    ::I18n.reload!

    ::I18n.default_locale = @mount_at_root

    # Reset fallbacks to fall back to our new default
    ::I18n.fallbacks = ::I18n::Locale::Fallbacks.new if ::I18n.respond_to?(:fallbacks)
  end

  Contract None => ArrayOf[Symbol]
  def known_languages
    if options[:langs]
      Array(options[:langs]).map(&:to_sym)
    else
      known_langs = file_watcher.known_paths.select do |p|
        p.to_s.match(@locales_regex) && (p.to_s.split(File::SEPARATOR).length == 2)
      end

      known_langs.map { |p|
        File.basename(p.to_s).sub(/\.ya?ml$/, '').sub(/\.rb$/, '')
      }.sort.map(&:to_sym)
    end
  end

  # Parse locale extension filename
  # @return [lang, path, basename]
  # will return +nil+ if no locale extension
  Contract String => Maybe[[Symbol, String, String]]
  def parse_locale_extension(path)
    path_bits = path.split('.')
    return nil if path_bits.size < 3

    lang = path_bits.delete_at(-2).to_sym
    return nil unless langs.include?(lang)

    path = path_bits.join('.')
    basename = File.basename(path_bits[0..-2].join('.'))
    [lang, path, basename]
  end

  Contract String, String, String, Symbol => IsA['Middleman::Sitemap::Resource']
  def build_resource(path, source_path, page_id, lang)
    old_locale = ::I18n.locale
    ::I18n.locale = lang
    localized_page_id = ::I18n.t("paths.#{page_id}", default: page_id, fallback: [])

    prefix = if (options[:mount_at_root] == lang) || (options[:mount_at_root].nil? && langs[0] == lang)
      '/'
    else
      replacement = options[:lang_map].fetch(lang, lang)
      options[:path].sub(':locale', replacement.to_s)
    end

    # path needs to be changed if file has a localizable extension. (options[mount_at_root] == lang)
    path = ::Middleman::Util.normalize_path(
      File.join(prefix, path.sub(page_id, localized_page_id))
    )

    path = path.sub(options[:templates_dir] + '/', '')

    p = ::Middleman::Sitemap::ProxyResource.new(app.sitemap, path, source_path)
    p.add_metadata locals: { lang: lang, page_id: path }, options: { lang: lang }

    ::I18n.locale = old_locale
    p
  end
end
