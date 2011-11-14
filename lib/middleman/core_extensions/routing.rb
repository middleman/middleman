module Middleman::CoreExtensions::Routing
  class << self
    def registered(app)
      app.extend ClassMethods
    end
    alias :included :registered
  end
  
  module ClassMethods
    # Takes a block which allows many pages to have the same layout
    # with_layout :admin do
    #   page "/admin/"
    #   page "/admin/login.html"
    # end
    def with_layout(layout_name, &block)
      old_layout = layout
    
      set :layout, layout_name
      class_eval(&block) if block_given?
    ensure
      set :layout, old_layout
    end
    
    # The page method allows the layout to be set on a specific path
    # page "/about.html", :layout => false
    # page "/", :layout => :homepage_layout
    def page(url, options={}, &block)
      options[:layout] = layout if options[:layout].nil?
      
      url = full_path(url)

      if options.has_key?(:proxy)
        reroute(url, options[:proxy])
        
        if options.has_key?(:ignore) && options[:ignore]
          ignore(options[:proxy])
          options.delete(:ignore)
        end  
        
        options.delete(:proxy)
      else
        if options.has_key?(:ignore) && options[:ignore]
          ignore(url)
          options.delete(:ignore)
        end
      end

      a_block = block_given? ? block : nil
      if a_block || !options.empty?
        sitemap.set_context(url, options, a_block)
      end
    end
  end
end