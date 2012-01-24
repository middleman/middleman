# Routing extension
module Middleman::CoreExtensions::Routing
  
  # Setup extension
  class << self
    
    # Once registered
    def registered(app)
      # Include methods
      app.send :include, InstanceMethods
    end
    
    alias :included :registered
  end
  
  # Routing instance methods
  module InstanceMethods
    
    # Takes a block which allows many pages to have the same layout
    #
    #   with_layout :admin do
    #     page "/admin/"
    #     page "/admin/login.html"
    #   end
    #
    # @param [String, Symbol] layout_name
    # @return [void]
    def with_layout(layout_name, &block)
      old_layout = layout
    
      set :layout, layout_name
      instance_exec(&block) if block_given?
    ensure
      set :layout, old_layout
    end
    
    # The page method allows the layout to be set on a specific path
    #
    #   page "/about.html", :layout => false
    #   page "/", :layout => :homepage_layout
    #
    # @param [String] url
    # @param [Hash] opts
    # @return [void]
    def page(url, opts={}, &block)
      a_block = block_given? ? block : nil
      
      # If the url is a regexp
      if url.is_a?(Regexp) || url.include?("*")
        
        # Use the metadata loop for matching against paths at runtime
        provides_metadata_for_path url do |url|
          { :options => opts, :blocks => [a_block] }
        end
        
        return
      end
      
      # Default layout
      opts[:layout] = layout if opts[:layout].nil?
      
      # Normalized path
      url = full_path(url)

      # Setup proxy
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
      
      # If we have a block or opts
      if a_block || !opts.empty?
        
        # Setup a metadata matcher for rendering those options
        provides_metadata_for_path url do |url|
          { :options => opts, :blocks => [a_block] }
        end
      end
    end
  end
end