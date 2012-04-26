# i18n Namespace
module Middleman::CoreExtensions::I18n

  # Setup extension
  class << self
    
    # Once registerd
    def registered(app)
      app.set :locales_dir, "locales"

      app.send :include, InstanceMethods
      
      # Needed for helpers as well
      app.after_configuration do
        # This is for making the tests work - since the tests
        # don't completely reload middleman, I18n.load_path can get
        # polluted with paths from other test app directories that don't 
        # exist anymore.
        ::I18n.load_path.delete_if {|path| path =~ %r{tmp/aruba}}
        ::I18n.load_path += Dir[File.join(root, locales_dir, "*.yml")]
        ::I18n.reload!
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
      @app.ignore File.join(@templates_dir, "**")
      
      @app.sitemap.provides_metadata_for_path do |url|
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
      
      @app.sitemap.register_resource_list_manipulator(
        :i18n,
        @app.i18n
      )
    end
    
    def langs
      @options[:langs] || begin
        Dir[File.join(@app.root, @app.locales_dir, "*.yml")].map { |file| 
          File.basename(file).gsub(".yml", "") 
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
      
        langs.map do |lang|
          ::I18n.locale = lang
        
          localized_page_id = ::I18n.t("paths.#{page_id}", :default => page_id)
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
      end
      
      resources + new_resources
    end
  end
  
  # Frontmatter class methods
  module InstanceMethods
    
    # Initialize the i18n
    def i18n
      @_i18n ||= Localizer.new(self)
    end
    
    # Main i18n API
    def localize(options={})
      settings.after_configuration do
        i18n.setup(options)
      end
    end
  end
end
