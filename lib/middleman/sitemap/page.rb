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
        forward_blocks = template.blocks.compact
        forward_blocks << block if block_given?
        store.page(proxied_to).template.render(*args) do
          forward_blocks.each do |block|
            instance_exec(&block)
          end
        end
      elsif !custom_renderer.nil?
        params = args.dup
        params << block if block_given?
        instance_exec(*params, &custom_renderer)
      else
        template.render(*args, &block)
      end
    end
    
  protected
    def app
      @store.app
    end
  end
end