require "i18n"
require "i18n/backend/fallbacks"

module Middleman
  module CoreExtensions

    # i18n Namespace
    module Internationalization

      # Setup extension
      class << self

        # Once registerd
        def registered(app, options={})
          app.config.define_setting :locales_dir, "locales", 'The directory holding your locale configurations'

          # Needed for helpers as well
          app.after_configuration do
            Localizer.new(self, options)
          end

          app.helpers do
            def t(*args)
              ::I18n.t(*args)
            end
          end

          # See https://github.com/svenfuchs/i18n/wiki/Fallbacks
          unless options[:no_fallbacks]
            ::I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
          end
        end
        alias :included :registered
      end

      # Central class for managing i18n extension
      class Localizer
        attr_reader :app
        delegate :logger, :to => :app

        def initialize(app, options={})
          @app = app
          @locales_glob = File.join(app.locales_dir, "**", "*.{rb,yml,yaml}")

          # File.fnmatch doesn't support brackets: {rb,yml,yaml}
          regex = @locales_glob.sub(/\./, '\.').sub(File.join("**", "*"), ".*").sub(/\//, '\/').sub("{rb,yml,yaml}", "rb|ya?ml")
          @locales_regex = %r{^#{regex}}

          @maps = {}
          @options = options

          ::I18n.load_path += Dir[File.join(app.root, @locales_glob)]
          ::I18n.reload!

          @lang_map      = @options[:lang_map]      || {}
          @path          = @options[:path]          || "/:locale/"
          @templates_dir = @options[:templates_dir] || "localizable"
          @mount_at_root = @options.has_key?(:mount_at_root) ? @options[:mount_at_root] : langs.first

          ::I18n.default_locale = @mount_at_root
          # Reset fallbacks to fall back to our new default
          if ::I18n.respond_to? :fallbacks
            ::I18n.fallbacks = ::I18n::Locale::Fallbacks.new
          end

          if !@app.build?
            logger.info "== Locales: #{langs.join(", ")} (Default #{@mount_at_root})"
          end

          # Don't output localizable files
          @app.ignore File.join(@templates_dir, "**")

          @app.sitemap.provides_metadata_for_path do |url|
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

          @app.sitemap.register_resource_list_manipulator(
            :i18n,
            self
          )

          @app.files.changed(&method(:on_file_changed))
          @app.files.deleted(&method(:on_file_changed))
        end

        def on_file_changed(file)
          if @locales_regex =~ file
            ::I18n.reload!
          end
        end

        def langs
          if @options[:langs]
            Array(@options[:langs]).map(&:to_sym)
          else
            Dir[File.join(@app.root, @locales_glob)].map { |file|
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
            next unless File.fnmatch(File.join(@templates_dir, "**"), resource.path)

            page_id = File.basename(resource.path, File.extname(resource.path))

            old_locale = ::I18n.locale
            langs.map do |lang|
              ::I18n.locale = lang

              localized_page_id = ::I18n.t("paths.#{page_id}", :default => page_id, :fallback => [])
              path = resource.path.sub(@templates_dir, "")

              # Build lang path
              if @mount_at_root == lang
                prefix = "/"
              else
                replacement = @lang_map.has_key?(lang) ? @lang_map[lang] : lang
                prefix = @path.sub(":locale", replacement.to_s)
              end

              path = ::Middleman::Util.normalize_path(
                File.join(prefix, path.sub(page_id, localized_page_id))
              )

              @_localization_data[path] = [lang, path, localized_page_id]

              p = ::Middleman::Sitemap::Resource.new(
                @app.sitemap,
                path
              )
              p.proxy_to(resource.path)

              new_resources << p
            end
            ::I18n.locale = old_locale

          end

          resources + new_resources
        end
      end
    end
  end
end
