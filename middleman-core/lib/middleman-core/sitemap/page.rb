# Sitemap namespace
module Middleman::Sitemap
  
  # Sitemap Page class
  class Page
    include Middleman::Sitemap::Extensions::Traversal
        
    # @return [Middleman::Base]
    attr_accessor :app
    
    # @return [Middleman::Sitemap::Base]
    attr_accessor :store
    
    # The source path of this page (relative to the source directory,
    # without template extensions)
    # @return [String]
    attr_accessor :path
    
    # The path of the page this page is proxied to, or nil if it's not proxied.
    # @return [String]
    attr_accessor :proxied_to
    
    delegate :metadata, :to => :template
    
    # Initialize page with parent store and URL
    # @param [Middleman::Sitemap::Base] store
    # @param [String] path
    # @param [String] source_file
    def initialize(store, path, source_file=nil)
      @store       = store
      @app         = @store.app
      @path        = path
      @source_file = source_file
      @proxied_to  = nil
    end
    
    # Whether this page has a template file
    # @return [Boolean]
    def template?
      if proxy?
        store.page(proxied_to).template?
      else
        return false if source_file.nil?
        !::Tilt[source_file].nil?
      end
    end
    
    # Internal path to be requested when rendering this page
    # @return [String]
    def request_path
      destination_path
    end
    
    # Set the on-disk source file for this page
    # @param [String] src
    # @return [void]
    def source_file=(src)
      @source_file = src
    end
    
    # The on-disk source file
    # @return [String]
    def source_file
      if proxy?
        store.page(proxied_to).source_file
      else
        @source_file
      end
    end
    
    # The template instance
    # @return [Middleman::Sitemap::Template]
    def template
      @_template ||= ::Middleman::Sitemap::Template.new(self)
    end
    
    # Extension of the path (i.e. '.js')
    # @return [String]
    def ext
      File.extname(path)
    end
    
    # Mime type of the path
    # @return [String]
    def mime_type
      app.mime_type ext
    end
    
    # Whether this page is a proxy
    # @return [Boolean]
    def proxy?
      !!@proxied_to
    end
    
    # Set this page to proxy to a target path
    # @param [String] target
    # @return [void]
    def proxy_to(target)
      @proxied_to = target
    end
    
    # Render this page
    # @return [String]
    def render(*args, &block)
      if template?
        if proxy?
          t = store.page(proxied_to).template
          t.request_path = path
          t.render(*args)
        else
          template.request_path = path
          template.render(*args, &block)
        end
      else # just a static file
        File.open(source_file).read
      end
    end
    
    # Whether this page either a directory index, or has the same name as an existing directory in the source
    # @return [Boolean]
    def directory_index?
      path.include?(app.index_file) || path =~ /\/$/ || eponymous_directory?
    end
    
    # Whether the page has the same name as a directory in the source
    # (e.g., if the page is named 'gallery.html' and a path exists named 'gallery/', this would return true)
    # @return [Boolean]
    def eponymous_directory?
      full_path = File.join(app.source_dir, eponymous_directory_path)
      !!(File.exists?(full_path) && File.directory?(full_path))
    end
    
    # The path for this page if it were a directory, and not a file
    # (e.g., for 'gallery.html' this would return 'gallery/')
    # @return [String]
    def eponymous_directory_path
      path.sub(File.extname(path), '/').sub(/\/$/, "") + "/"
    end
    
    # A path without the directory index - so foo/index.html becomes
    # just foo. Best for linking.
    # @return [String]
    def url
      '/' + destination_path.sub(/#{Regexp.escape(app.index_file)}$/, '')
    end

    # Get the relative path from the source
    # @return [String]
    def relative_path
      self.source_file ? self.source_file.sub(app.source_dir, '') : nil
    end

    # Get the destination path, relative to the build directory.
    # This path can be affected by proxy callbacks.
    # @return [String]
    def destination_path
      store.reroute_callbacks.inject(self.path) do |destination, callback|
        callback.call(destination, self)
      end
    end
    
    # This page's frontmatter
    # @return [Hash]
    def data
      app.frontmatter(relative_path).first
    end
  end
end
