module Middleman::CoreExtensions::Routing
  class << self
    def registered(app)
      app.extend ClassMethods
    end
    alias :included :registered
  end
  
  module ClassMethods
    def path_to_index(path)
      parts = path ? path.split('/') : []
      if parts.last.nil? || parts.last.split('.').length == 1
        path = File.join(path, index_file) 
      end
      path.gsub(%r{^/}, '')
    end
  
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
  
    def paths_for_url(url)
      url = url.gsub(%r{\/#{index_file}$}, "")
      url = url.gsub(%r{(\/)$}, "") if url.length > 1
    
      paths = [url]
      paths << "#{url}/" if url.length > 1 && url.split("/").last.split('.').length <= 1
      paths << "/#{path_to_index(url)}"
      paths
    end
    
    # The page method allows the layout to be set on a specific path
    # page "/about.html", :layout => false
    # page "/", :layout => :homepage_layout
    def page(url, options={}, &block)
      has_block = block_given?
      options[:layout] = layout if options[:layout].nil?

      if options.has_key?(:proxy)
        reroute(url, options[:proxy])
        
        if options.has_key?(:ignore) && options[:ignore]
          ignore(options[:proxy])
        end  
        
        options.delete(:proxy)
      else
        if options.has_key?(:ignore) && options[:ignore]
          ignore(url)
        end
      end
      
      paths_for_url(url).each do |p|
        get(p) do
          if settings.sitemap.path_is_proxy?(url)
            request["is_proxy"] = true
            request.path_info = settings.sitemap.path_target(url)
          end
          
          instance_eval(&block) if has_block
          process_request(options)
        end
      end
    end
  end
end