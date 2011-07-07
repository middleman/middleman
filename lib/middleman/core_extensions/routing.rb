module Middleman::CoreExtensions::Routing
  class << self
    def registered(app)
      app.extend ClassMethods
      
      # Normalize the path and add index if we're looking at a directory
      app.before do
        request.path_info = self.class.path_to_index(request.path)
      end
    end
    alias :included :registered
  end
  
  module ClassMethods
    def current_layout
      @layout
    end
    
    def path_to_index(path)
      parts = path ? path.split('/') : []
      if parts.last.nil? || parts.last.split('.').length == 1
        path = File.join(path, settings.index_file) 
      end
      path.gsub(%r{^/}, '')
    end
  
    # Takes a block which allows many pages to have the same layout
    # with_layout :admin do
    #   page "/admin/"
    #   page "/admin/login.html"
    # end
    def with_layout(layout_name, &block)
      old_layout = current_layout
    
      layout(layout_name)
      class_eval(&block) if block_given?
    ensure
      layout(old_layout)
    end
  
    # The page method allows the layout to be set on a specific path
    # page "/about.html", :layout => false
    # page "/", :layout => :homepage_layout
    def page(url, options={}, &block)
      url = url.gsub(%r{#{settings.index_file}$}, "")
      url = url.gsub(%r{(\/)$}, "") if url.length > 1
    
      paths = [url]
      paths << "#{url}/" if url.length > 1 && url.split("/").last.split('.').length <= 1
      paths << "#{path_to_index(url)}"

      options[:layout] = current_layout if options[:layout].nil?

      paths.each do |p|
        get(p) do
          return yield if block_given?
          process_request(options)
        end
      end
    end
  end
end