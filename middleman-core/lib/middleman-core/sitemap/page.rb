module Middleman::Sitemap
  class Page
    attr_accessor :store, :path, :proxied_to, :status
    
    def initialize(store, path)
      @store       = store
      @path        = path
      @status      = :generic
      @source_file = nil
      @proxied_to  = nil
    end
    
    def template?
      if proxy?
        store.page(proxied_to).template?
      else
        return false if source_file.nil?
        !::Tilt[source_file].nil?
      end
    end
    
    def source_file=(src)
      @source_file = src
    end
    
    def request_path
      if proxy?
        store.page(proxied_to).path
      else
        path
      end
    end
    
    def source_file
      if proxy?
        store.page(proxied_to).source_file
      else
        @source_file
      end
    end
    
    def template
      @_template ||= ::Middleman::Sitemap::Template.new(self)
    end
    
    def ext
      File.extname(path)
    end
    
    def mime_type
      app.mime_type ext
    end
    
    def proxy?
      @status == :proxy
    end
    
    def proxy_to(target)
      @status = :proxy
      @proxied_to = target
    end
    
    def generic?
      @status == :generic
    end
    
    def make_generic
      @status = :generic
    end
    
    def ignored?
      @status == :ignored
    end
    
    def ignore
      @status = :ignored
    end
    
    def touch
      template.touch if template?
    end
    
    def custom_renderer(&block)
      @_custom_renderer ||= nil
      @_custom_renderer = block if block_given?
      @_custom_renderer
    end
    
    def render(*args, &block)
      return unless template?
      
      if proxy?
        # Forward blocks
        # forward_blocks = template.blocks.compact
        # forward_blocks << block if block_given?
        t = store.page(proxied_to).template
        t.request_path = path
        t.render(*args)
         # do
         #          forward_blocks.each do |block|
         #            instance_exec(&block)
         #          end
         #        end
      elsif !custom_renderer.nil?
        params = args.dup
        params << block if block_given?
        instance_exec(*params, &custom_renderer)
      else
        template.request_path = path
        template.render(*args, &block)
      end
    end
    
    def directory_index?
      path.include?(app.index_file) || path =~ /\/$/ || eponymous_directory?
    end

    def eponymous_directory?
      !!Dir.exists?(File.join(app.source_dir, eponymous_directory_path))
    end
    
    def eponymous_directory_path
      path.sub('.html', '/').sub(/\/$/, "") + "/"
    end
    
    def relative_path
      source_file.sub(app.source_dir, '')
    end
    
    def data
      data, content = app.frontmatter(relative_path)
      data || nil
    end
    
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
    
    def siblings
      return [] unless parent
      parent.children.reject { |p| p == self }
    end
    
  protected
    def app
      @store.app
    end
  end
end