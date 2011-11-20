module Middleman::CoreExtensions::Routing
  class << self
    def registered(app)
      app.send :include, InstanceMethods
    end
    alias :included :registered
  end
  
  module InstanceMethods
    # Takes a block which allows many pages to have the same layout
    # with_layout :admin do
    #   page "/admin/"
    #   page "/admin/login.html"
    # end
    def with_layout(layout_name, &block)
      old_layout = layout
    
      set :layout, layout_name
      instance_exec(&block) if block_given?
    ensure
      set :layout, old_layout
    end
    
    # The page method allows the layout to be set on a specific path
    # page "/about.html", :layout => false
    # page "/", :layout => :homepage_layout
    def page(url, opts={}, &block)
      opts[:layout] = layout if opts[:layout].nil?
      
      url = full_path(url)

      if opts.has_key?(:proxy)
        reroute(url, opts[:proxy])
        
        if opts.has_key?(:ignore) && opts[:ignore]
          ignore(opts[:proxy])
          opts.delete(:ignore)
        end  
        
        opts.delete(:proxy)
      else
        if opts.has_key?(:ignore) && opts[:ignore]
          ignore(url)
          opts.delete(:ignore)
        end
      end

      a_block = block_given? ? block : nil
      if a_block || !opts.empty?
        sitemap.page(url) do
          template.options = opts
          template.blocks  = [a_block]
        end
      end
    end
  end
end