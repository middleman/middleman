# i18n Namespace
module Middleman::CoreExtensions::I18n

  # Setup extension
  class << self
    
    # Once registerd
    def registered(app)
      app.set :locales_dir, "locales"

      app.send :include, InstanceMethods
      
      app.after_configuration do
        ::I18n.load_path += Dir[File.join(root, locales_dir, "*.yml")]
      end
    end
    alias :included :registered
  end
  
  class Localizer
    def initialize(app)
      @app = app
      @maps = {}
    end
    
    def setup(options)
      @options = options
      
      @lang_map      = @options[:lang_map]      || {}
      @path          = @options[:path]          || "/:locale/"
      @templates_dir = @options[:templates_dir] || "localizable"
      @mount_at_root = @options.has_key?(:mount_at_root) ? @options[:mount_at_root] : langs.first
      
      if !@app.build?
        puts "== Locales: #{langs.join(", ")}"
      end
      
      # Don't output localizable files
      ignore File.join(@templates_dir, "**/*")
      
      provides_metadata_for_path do |url|
        if d = get_localization_data(url)
          lang, page_id = d
          instance_vars = Proc.new {
            ::I18n.locale = lang
            @lang         = lang
            @page_id      = page_id
          }
          { :blocks => [instance_vars] }
        else
          {}
        end
      end
    end
    
    def langs
      @options[:langs] || begin
        Dir[File.join(@app.root, @app.locales_dir, "*.yml")].map do |file|
          File.basename(file).gsub(".yml", "").to_sym
        end
      end
    end

    def get_localization_data(url)
      if @mount_at_root
      else
      end
    end
    
    # def paths_for_file(file)
    #   url = @app.sitemap.source_map.index(file)
    #   page_id = File.basename(url, File.extname(url))
    #   
    #   langs.map do |lang|
    #     ::I18n.locale = lang
    #     
    #     # Build lang path
    #     if @mount_at_root == lang
    #       prefix = "/"
    #     else
    #       replacement = @lang_map.has_key?(lang) ? @lang_map[lang] : lang
    #       prefix = @path.sub(":locale", replacement.to_s)
    #     end
    #     
    #     localized_page_id = ::I18n.t("paths.#{page_id}", :default => page_id)
    #     
    #     path = File.join(prefix, url.sub(page_id, localized_page_id))
    #     [lang, path, localized_page_id]
    #   end
    # end
  end
  
  # Frontmatter class methods
  module InstanceMethods
    
    # Initialize the i18n
    def i18n
      @i18n ||= Localizer.new(self)
    end
    
    # Main i18n API
    def localize(options={})
      settings.after_configuration do
        i18n.setup(options)
      end
    end
  end
end