class Middleman::CoreExtensions::Internationalization < ::Middleman::Extension
  option :no_fallbacks, false, "Disable I18n fallbacks"
  option :langs, nil, "List of langs, will autodiscover by default"
  option :lang_map, {}, "Language shortname map"
  option :path, "/:locale/", "URL prefix path"
  option :templates_dir, "localizable", "Location of templates to be localized"
  option :mount_at_root, nil, "Mount a specific language at the root of the site"
  option :data, "locales", "The directory holding your locale configurations"

  def initialize(app, options_hash={}, &block)
    super

    # See https://github.com/svenfuchs/i18n/wiki/Fallbacks
    unless options[:no_fallbacks]
      require "i18n/backend/fallbacks"
      ::I18n::Backend::Simple.send(:include, ::I18n::Backend::Fallbacks)
    end

    app.config.define_setting :locales_dir, "locales", 'The directory holding your locale configurations'

    app.send :include, LocaleHelpers
  end

  def after_configuration
    @locales_glob = File.join(app.config[:locals_dir] || options[:data], "**", "*.{rb,yml,yaml}")

    # File.fnmatch doesn't support brackets: {rb,yml,yaml}
    regex = @locales_glob.sub(/\./, '\.').sub(File.join("**", "*"), ".*").sub(/\//, '\/').sub("{rb,yml,yaml}", "rb|ya?ml")
    @locales_regex = %r{^#{regex}}

    @maps = {}

    ::I18n.load_path += Dir[File.join(app.root, @locales_glob)]
    ::I18n.reload!

    @mount_at_root = options[:mount_at_root].nil? ? langs.first : options[:mount_at_root]

    ::I18n.default_locale = @mount_at_root
    # Reset fallbacks to fall back to our new default
    if ::I18n.respond_to? :fallbacks
      ::I18n.fallbacks = ::I18n::Locale::Fallbacks.new
    end

    if !app.build?
      logger.info "== Locales: #{langs.join(", ")} (Default #{@mount_at_root})"
    end

    # Don't output localizable files
    app.ignore File.join(options[:templates_dir], "**")

    app.sitemap.provides_metadata_for_path do |url|
      if d = get_localization_data(url)
        lang, page_id = d
      else
        # Default to the @mount_at_root lang
        page_id = nil
        lang = @mount_at_root
      end

      instance_vars = Proc.new do
        @lang         = lang
        @page_id      = page_id
      end

      locals = { :lang => lang,
        :page_id => page_id }
      { :blocks => [instance_vars],
        :locals => locals,
        :options => { :lang => lang } }
    end

    app.files.changed(&method(:on_file_changed))
    app.files.deleted(&method(:on_file_changed))
  end

  helpers do
    def t(*args)
      ::I18n.t(*args)
    end
  end

  delegate :logger, :to => :app

  def on_file_changed(file)
    if @locales_regex =~ file
      ::I18n.reload!
    end
  end

  def langs
    if options[:langs]
      Array(options[:langs]).map(&:to_sym)
    else
      Dir[File.join(app.root, @locales_glob)].map { |file|
        File.basename(file).sub(/\.ya?ml$/, "").sub(/\.rb$/, "")
      }.sort.map(&:to_sym)
    end
  end

  def get_localization_data(path)
    @_localization_data ||= {}
    @_localization_data[path]
  end

  # Update the main sitemap resource list
  # @return [void]
  def manipulate_resource_list(resources)
    @_localization_data = {}

    new_resources = []

    resources.each do |resource|
      # If it's a "localizable template"
      if File.fnmatch?(File.join(options[:templates_dir], "**"), resource.path)
        page_id = File.basename(resource.path, File.extname(resource.path))
        langs.each do |lang|
          # Remove folder name
          path = resource.path.sub(options[:templates_dir], "")
          new_resources << build_resource(path, resource.path, page_id, lang)
        end
      elsif result = parse_locale_extension(resource.path)
        lang, path, page_id = result
        new_resources << build_resource(path, resource.path, page_id, lang)
      end
    end

    resources + new_resources
  end

  private

  # Parse locale extension filename
  # @return [lang, path, basename]
  # will return +nil+ if no locale extension
  def parse_locale_extension(path)
    path_bits = path.split('.')
    return nil if path_bits.size < 3

    lang = path_bits.delete_at(-2).to_sym
    return nil unless langs.include?(lang)

    path = path_bits.join('.')
    basename = File.basename(path_bits[0..-2].join('.'))

    [lang, path, basename]
  end

  def build_resource(path, source_path, page_id, lang)
    old_locale = ::I18n.locale
    ::I18n.locale = lang

    localized_page_id = ::I18n.t("paths.#{page_id}", :default => page_id, :fallback => [])

    if @mount_at_root == lang
      prefix = "/"
    else
      replacement = options[:lang_map].fetch(lang, lang)
      prefix = options[:path].sub(":locale", replacement.to_s)
    end

    path = ::Middleman::Util.normalize_path(
       File.join(prefix, path.sub(page_id, localized_page_id))
    )

    @_localization_data[path] = [lang, path, localized_page_id]

    p = ::Middleman::Sitemap::Resource.new(app.sitemap, path)
    p.proxy_to(source_path)

    ::I18n.locale = old_locale

    p
  end

  module LocaleHelpers
    # Access the list of languages supported by this Middleman application
    # @return [Array<Symbol>]
    def langs
      extensions[:i18n].langs
    end
  end
end
