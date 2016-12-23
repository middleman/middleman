class Middleman::CoreExtensions::Internationalization < ::Middleman::Extension
  option :no_fallbacks, false, 'Disable I18n fallbacks'
  option :locales, nil, 'List of locales, will autodiscover by default'
  option :langs, nil, 'Backwards compatibility if old option name. Use `locales` instead.'
  option :locale_map, {}, 'Locale shortname map'
  option :lang_map, nil, 'Backwards compatibility if old option name. Use `locale_map` instead.'
  option :path, '/:locale/', 'URL prefix path'
  option :templates_dir, 'localizable', 'Location of templates to be localized'
  option :mount_at_root, nil, 'Mount a specific locale at the root of the site'
  option :data, 'locales', 'The directory holding your locale configurations'

  # Exposes `locales` to templates
  expose_to_template :locales, :langs, :locale, :lang

  def initialize(*)
    super

    require 'i18n'

    options[:locales] = options[:langs] unless options[:langs].nil?

    options[:locale_map] = options[:lang_map] unless options[:lang_map].nil?

    # Don't fail on invalid locale, that's not what our current
    # users expect.
    ::I18n.enforce_available_locales = false

    # This is for making the tests work - since the tests
    # don't completely reload middleman, I18n.load_path can get
    # polluted with paths from other test app directories that don't
    # exist anymore.
    if ENV['TEST']
      app.after_configuration_eval do
        ::I18n.load_path.delete_if { |path| path =~ %r{tmp/aruba} }
        ::I18n.reload!
      end
    end
  end

  def after_configuration
    # See https://github.com/svenfuchs/i18n/wiki/Fallbacks
    unless options[:no_fallbacks]
      require 'i18n/backend/fallbacks'
      ::I18n::Backend::Simple.send(:include, ::I18n::Backend::Fallbacks)
    end

    locales_file_path = options[:data]

    # Tell the file watcher to observe the :data_dir
    app.files.watch :locales,
                    path: File.join(app.root, locales_file_path),
                    only: /.*(rb|yml|yaml)$/

    # Setup data files before anything else so they are available when
    # parsing config.rb
    app.files.on_change(:locales, &method(:on_file_changed))

    @maps = {}
    @mount_at_root = options[:mount_at_root].nil? ? locales.first : options[:mount_at_root]

    configure_i18n

    logger.info "== Locales: #{locales.join(', ')} (Default #{@mount_at_root})"
  end

  helpers do
    def t(*args)
      ::I18n.t(*args)
    end

    def url_for(path_or_resource, options={})
      locale = options.delete(:locale) || ::I18n.locale

      opts = options.dup

      should_relativize = opts.key?(:relative) ? opts[:relative] : config[:relative_links]

      opts[:relative] = false

      href = super(path_or_resource, opts)

      final_path = if result = extensions[:i18n].localized_path(href, locale)
        result
      else
        # Should we log the missing file?
        href
      end

      opts[:relative] = should_relativize

      begin
        super(final_path, opts)
      rescue RuntimeError
        super(path_or_resource, options)
      end
    end

    def locate_partial(partial_name, try_static=false)
      locals_dir = extensions[:i18n].options[:templates_dir]

      # Try /localizable
      partials_path = File.join(locals_dir, partial_name)

      locale_suffix = ::I18n.locale

      extname = File.extname(partial_name)
      maybe_static = !extname.empty?
      suffixed_partial_name = if maybe_static
        partial_name.sub(extname, ".#{locale_suffix}#{extname}")
      else
        "#{partial_name}.#{locale_suffix}"
      end

      if locale_suffix
        super(suffixed_partial_name, maybe_static) ||
          super(File.join(locals_dir, suffixed_partial_name), maybe_static) ||
          super(partials_path, try_static) ||
          super
      else
        super(partials_path, try_static) ||
          super
      end
    end
  end

  Contract ArrayOf[Symbol]
  def locales
    @locales ||= known_locales
  end

  # Backwards API compat
  alias langs locales

  Contract Symbol
  def locale
    ::I18n.locale
  end

  # Backwards API compat
  alias lang locale

  # Update the main sitemap resource list
  # @return Array<Middleman::Sitemap::Resource>
  Contract ResourceList => ResourceList
  def manipulate_resource_list(resources)
    new_resources = []

    file_extension_resources = resources.select do |resource|
      parse_locale_extension(resource.path)
    end

    localizable_folder_resources = resources.select do |resource|
      !file_extension_resources.include?(resource) && File.fnmatch?(File.join(options[:templates_dir], '**'), resource.path)
    end

    # If it's a "localizable template"
    localizable_folder_resources.each do |resource|
      page_id = File.basename(resource.path, File.extname(resource.path))
      locales.each do |locale|
        # Remove folder name
        path = resource.path.sub(options[:templates_dir], '')
        new_resources << build_resource(path, resource.path, page_id, locale)
      end

      resource.ignore!

      # This is for backwards compatibility with the old provides_metadata-based code
      # that used to be in this extension, but I don't know how much sense it makes.
      # next if resource.options[:locale]

      # $stderr.puts "Defaulting #{resource.path} to #{@mount_at_root}"
      # resource.add_metadata options: { locale: @mount_at_root }, locals: { locale: @mount_at_root }
    end

    # If it uses file extension localization
    file_extension_resources.each do |resource|
      result = parse_locale_extension(resource.path)
      ext_locale, path, page_id = result
      new_resources << build_resource(path, resource.path, page_id, ext_locale)

      resource.ignore!
    end

    @lookup = new_resources.each_with_object({}) do |desc, sum|
      abs_path = desc.source_path.sub(options[:templates_dir], '')
      sum[abs_path] ||= {}
      sum[abs_path][desc.locale] = '/' + desc.path
    end

    new_resources.reduce(resources) do |sum, r|
      r.execute_descriptor(app, sum)
    end
  end

  Contract String, Symbol => Maybe[String]
  def localized_path(path, locale)
    lookup_path = path.dup
    lookup_path << app.config[:index_file] if lookup_path.end_with?('/')

    @lookup[lookup_path] && @lookup[lookup_path][locale]
  end

  Contract Symbol => String
  def path_root(locale)
    if (options[:mount_at_root] == locale) || (options[:mount_at_root].nil? && locales[0] == locale)
      '/'
    else
      replacement = options[:locale_map][locale] || locale
      options[:path].sub(':locale', replacement.to_s).sub(':lang', replacement.to_s) # Backward compat
    end
  end

  private

  def on_file_changed(_updated_files, _removed_files)
    ::I18n.load_path |= app.files.by_type(:locales).files.map { |p| p[:full_path].to_s }
    ::I18n.reload!

    @app.sitemap.rebuild_resource_list!(:touched_locale_file)
  end

  def configure_i18n
    ::I18n.load_path |= app.files.by_type(:locales).files.map { |p| p[:full_path].to_s }
    ::I18n.reload!

    ::I18n.default_locale = @mount_at_root

    # Reset fallbacks to fall back to our new default
    ::I18n.fallbacks = ::I18n::Locale::Fallbacks.new if ::I18n.respond_to?(:fallbacks)
  end

  Contract ArrayOf[Symbol]
  def known_locales
    if options[:locales]
      Array(options[:locales]).map(&:to_sym)
    else
      known_locales = app.files.by_type(:locales).files.select do |p|
        p[:relative_path].to_s.split(File::SEPARATOR).length == 1
      end

      known_locales.map do |p|
        File.basename(p[:relative_path].to_s).sub(/\.ya?ml$/, '').sub(/\.rb$/, '')
      end.sort.map(&:to_sym)
    end
  end

  # Parse locale extension filename
  # @return [locale, path, basename]
  # will return +nil+ if no locale extension
  Contract String => Maybe[[Symbol, String, String]]
  def parse_locale_extension(path)
    path_bits = path.split('.')
    return nil if path_bits.size < 3

    locale = path_bits.delete_at(-2).to_sym
    return nil unless locales.include?(locale)

    path = path_bits.join('.')
    basename = File.basename(path_bits[0..-2].join('.'))
    [locale, path, basename]
  end

  LocalizedPageDescriptor = Struct.new(:path, :source_path, :locale) do
    def execute_descriptor(app, resources)
      r = ::Middleman::Sitemap::ProxyResource.new(app.sitemap, path, source_path)
      r.add_metadata options: { locale: locale }
      resources + [r]
    end
  end

  Contract String, String, String, Symbol => LocalizedPageDescriptor
  def build_resource(path, source_path, page_id, locale)
    old_locale = ::I18n.locale
    ::I18n.locale = locale
    localized_page_id = ::I18n.t("paths.#{page_id}", default: page_id, fallback: [])

    partially_localized_path = ''

    File.dirname(path).split('/').each do |path_sub|
      next if path_sub == ''
      partially_localized_path = "#{partially_localized_path}/#{::I18n.t("paths.#{path_sub}", default: path_sub)}"
    end

    path = "#{partially_localized_path}/#{File.basename(path)}"

    prefix = path_root(locale)

    # path needs to be changed if file has a localizable extension. (options[mount_at_root] == locale)
    path = ::Middleman::Util.normalize_path(
      File.join(prefix, path.sub(page_id, localized_page_id))
    )

    path = path.sub(options[:templates_dir] + '/', '')

    ::I18n.locale = old_locale

    LocalizedPageDescriptor.new(path, source_path, locale)
  end
end
