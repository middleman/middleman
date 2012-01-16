# Sitemap namespace
module Middleman::Sitemap
  
  # Sitemap Page class
  class Page
    # @return [Middleman::Sitemap::Store]
    attr_accessor :store
    
    # @return [String]
    attr_accessor :path
    
    # @return [Middleman::Sitemap::Page]
    attr_accessor :proxied_to
    
    # @return [Symbol]
    attr_accessor :status
    
    # Initialize page with parent store and URL
    # @param [Middleman::Sitemap::Store] store
    # @param [String] path
    def initialize(store, path)
      @store       = store
      @path        = path
      @status      = :generic
      @source_file = nil
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
      if proxy?
        store.page(proxied_to).path
      else
        path
      end
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
    
    # Extension of the path
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
      @status == :proxy
    end
    
    # Set this page to proxy to a target path
    # @param [String] target
    # @return [void]
    def proxy_to(target)
      @status = :proxy
      @proxied_to = target
    end
    
    # Whether this page is a generic page
    # @return [Boolean]
    def generic?
      @status == :generic
    end
    
    # Set this page to be a generic page
    # @return [void]
    def make_generic
      @status = :generic
      # TODO: Remove from ignore array?
    end
    
    # Whether this page is ignored
    # @return [Boolean]
    def ignored?
      return true if store.ignored?(self.path)
            
      if !@source_file.nil?
        relative_source = @source_file.sub(app.source_dir, '')
        if self.path.sub(/^\//, "") != relative_source.sub(/^\//, "")
          store.ignored?(relative_source)
        else
          false
        end
      else
        false
      end
    end
    
    # Set this page to be ignored
    # @return [void]
    def ignore
      store.ignore(self.path)
    end
    
    # If this is a template, refresh contents
    # @return [void]
    def touch
      template.touch if template?
    end
    
    # If this is a template, remove contents
    # @return [void]
    def delete
      template.delete if template?
    end
    
    # Render this page
    # @return [String]
    def render(*args, &block)
      return unless template?
      
      if proxy?
        t = store.page(proxied_to).template
        t.request_path = path
        t.render(*args)
      else
        template.request_path = path
        template.render(*args, &block)
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
      !!Dir.exists?(File.join(app.source_dir, eponymous_directory_path))
    end
    
    # The path for this page if it were a directory, and not a file
    # (e.g., for 'gallery.html' this would return 'gallery/')
    # @return [String]
    def eponymous_directory_path
      path.sub('.html', '/').sub(/\/$/, "") + "/"
      # TODO: Seems like .html shouldn't be hardcoded here
    end
    
    # Get the relative path from the source
    # @return [String]
    def relative_path
      self.source_file ? self.source_file.sub(app.source_dir, '') : nil
    end
    
    # This page's frontmatter
    # @return [Hash, nil]
    def data
      data, content = app.frontmatter(relative_path)
      data || nil
    end
    
    # This page's parent page
    # @return [Middleman::Sitemap::Page, nil]
    def parent
      parts = path.split("/")
      if path.include?(app.index_file)
        parts.pop
      else
      end
      
      return nil if parts.length < 1
      
      parts.pop
      parts.push(app.index_file)
      
      parent_path = "/" + parts.join("/")
      
      if store.exists?(parent_path)
        store.page(parent_path)
      else
        nil
      end
    end
    
    # This page's child pages
    # @return [Array<Middleman::Sitemap::Page>]
    def children
      return [] unless directory_index?

      if eponymous_directory?
        base_path = eponymous_directory_path
        prefix    = /^#{base_path.sub("/", "\\/")}/
      else
        base_path = path.sub("#{app.index_file}", "")
        prefix    = /^#{base_path.sub("/", "\\/")}/
      end
            
      store.all_paths.select do |sub_path|
        sub_path =~ prefix
      end.select do |sub_path|
        path != sub_path
      end.select do |sub_path|
       inner_path = sub_path.sub(prefix, "")
       parts = inner_path.split("/")
       if parts.length == 1
         true
       elsif parts.length == 2
         parts.last == app.index_file
       else
         false
       end
      end.map do |p| 
        store.page(p)
      end.reject { |p| p.ignored? }
    end
    
    # This page's sibling pages
    # @return [Array<Middleman::Sitemap::Page>]
    def siblings
      return [] unless parent
      parent.children.reject { |p| p == self }
    end
    
  protected
  
    # This page's stored app
    # @return [Middleman::Base]
    def app
      store.app
    end
  end
end