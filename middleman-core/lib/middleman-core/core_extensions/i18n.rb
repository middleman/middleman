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
  attr_reader :lookup

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
    app.after_configuration_eval do
      ::I18n.load_path.delete_if { |path| path =~ %r{tmp/aruba} }
      ::I18n.reload!
    end if ENV['TEST']
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

      # Backup options in case there's an error
      opts = options.dup


      should_relativize = if opts.key?(:relative)
        opts[:relative]
      else
        config[:relative_links]
      end

      opts[:relative] = false
      # We will call super at first without relative
      # until we figure out what's going on


      # Me too, I have no idea if what I got is a path or resource.
      # But I need the potential resource to figure out the page_id,
      # if there's one, and if so, see if there's a localization
      # available

      # Look if this stringish designates a resource
      # Copied from M::Util::Paths#url_for:153
      if path_or_resource.is_a?(String) || path_or_resource.is_a?(Symbol)
        if r = app.sitemap.find_resource_by_page_id(path_or_resource)
          path_or_resource = r
        elsif r = app.sitemap.find_resource_by_path(path_or_resource)
          path_or_resource = r
        end
      end

      # If stringish designates a resource, transform p_o_r into
      # the path with locale
      if path_or_resource.is_a?(::Middleman::Sitemap::Resource)
        page_id = path_or_resource.page_id

        final_path =
          if result = extensions[:i18n].localized_path(page_id, locale)
            result
          else
            # Should we log the missing file?
            path_or_resource
          end
      else
        final_path = path_or_resource
      end

      opts[:relative] = should_relativize

      begin
        super(final_path, opts)
      # rescue RuntimeError
      #   super(path_or_resource, options)
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

    def other_locale
      if extensions[:i18n].langs.count > 2
        raise "There is more than one other locale to choose"\
          "from. Use `other_locales` to get them all."
      end

      other_locales[0]
    end

    def other_locales
      extensions[:i18n].langs - [I18n.locale]
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
    @lookup ||= {}

    new_resources = []

    [FileExtensionResource, LocalizableResource].map do |type|
      new_resources << type.find_in(resources, i18n: self).map(&:build)
    end

    new_resources.flatten.reduce(resources) do |sum, r|
      r.execute_descriptor(app, sum)
    end
  end

  Contract String, Symbol => Maybe[String]
  def localized_path(page_id, locale)
    @lookup[page_id] && @lookup[page_id][locale]
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

  # Those are 'source' resource not destination
  class I18nResource
    attr_reader :resource, :i18n

    def initialize(resource, i18n)
      @resource = resource
      @i18n = i18n
    end
  end

  class LocalizableResource < I18nResource
    def self.find_in(resources, i18n:)
      resources.each_with_object([]) do |resource, output|
        is_localizable = File.fnmatch?(
          File.join(i18n.options[:templates_dir], '**'), resource.path
        )

        output << new(resource, i18n) if !resource.ignored? && is_localizable
      end
    end

    def build
      # Remove folder name
      path = resource.path.sub(i18n.options[:templates_dir], '')
      page_id = resource.page_id.sub(i18n.options[:templates_dir] + '/', '')

      result = i18n.locales.map do |locale|
        i18n.send(:build_resource, *[path, resource.path, page_id, locale])
      end

      resource.ignore!

      result
    end
  end

  class FileExtensionResource < I18nResource
    def self.find_in(resources, i18n:)
      # File extension resources are the ones that return a true parse
      resources.each_with_object([]) do |resource, output|
        output << new(resource, i18n) if parse_locale_extension(resource.path, i18n: i18n)[0]
      end
    end

    def build
      ext_locale, path = self.class.parse_locale_extension(resource.path, i18n: i18n)
      _, page_id = self.class.parse_locale_extension(resource.page_id, i18n: i18n, has_last: false)

      # result = i18n.build_resource(path, resource.path, page_id, ext_locale)
      result = i18n.send(:build_resource, *[path, resource.path, page_id, ext_locale])
      resource.ignore!

      result
    end

    # Parse locale extension filename or page_id when implicit
    #
    # Page id could have no extension if set manually
    #
    # @return [locale, result]
    # will return +nil+ if no locale extension

    # Contract String, Hash => [Maybe[Symbol], String]
    def self.parse_locale_extension(pathish, i18n:, has_last: true)
      dirname = File.dirname(pathish)
      basename = File.basename(pathish)

      path_bits = basename.split('.')

      locale_index = has_last ? -2 : -1
      locale = path_bits[locale_index].try(:to_sym)

      if i18n.locales.include?(locale)
        path_bits.delete_at(locale_index)
      else
        locale = nil
      end

      pathish = path_bits.join('.')
      pathish = File.join(dirname, pathish) unless dirname == '.'

      [locale, pathish]
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

  LocalizedPageDescriptor = Struct.new(:path, :source_path, :page_id, :locale) do
    def execute_descriptor(app, resources)
      r = ::Middleman::Sitemap::ProxyResource.new(app.sitemap, path, source_path)
      r.add_metadata page: {id: page_id}, options: { locale: locale }
      resources + [r]
    end
  end

  # Build destination resource
  Contract String, String, String, Symbol => LocalizedPageDescriptor
  def build_resource(path, source_path, page_id, locale)
    old_locale = ::I18n.locale
    ::I18n.locale = locale
    localized_page_id = ::I18n.t("paths.#{page_id}", default: page_id,
                                 fallback: [])

    partially_localized_path = ''

    File.dirname(path).split('/').each do |path_sub|
      next if ['', '.'].include?(path_sub)

      partially_localized_path = "#{partially_localized_path}/#{::I18n.t("paths.#{path_sub}", default: path_sub)}"
    end

    path = "#{partially_localized_path}/#{File.basename(path)}"

    prefix = path_root(locale)

    # path needs to be changed if file has a localizable extension. (options[mount_at_root] == locale)
    path = ::Middleman::Util.normalize_path(
      File.join(prefix, path.sub(page_id, localized_page_id))
    )

    path = path.sub(options[:templates_dir] + '/', '')

    @lookup[page_id] ||= {}
    @lookup[page_id][locale] = '/' + path

    ::I18n.locale = old_locale

    LocalizedPageDescriptor.new(path, source_path, page_id, locale)
  end
end
