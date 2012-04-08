# Sitemap namespace
module Middleman::Sitemap

  # Template class
  class Template
    
    # @return [Middleman::Sitemap::Page]
    attr_accessor :page
    
    # @return [Hash]
    attr_accessor :options
    
    # @return [Hash]
    attr_accessor :locals
    
    # @return [String]
    attr_accessor :request_path
  
    # Initialize template with parent page
    # @param [Middleman::Sitemap:Page] page
    def initialize(page)
      @page    = page
      @options = {}
      @locals  = {}
      @blocks  = []
    end
  
    # Simple aliases
    delegate :path, :source_file, :store, :app, :ext, :to => :page
    
    # Get the metadata for both the current source_file and the current path
    # @return [Hash]
    def metadata
      metadata = app.metadata_for_file(source_file)
      metadata = metadata.deep_merge(app.metadata_for_path(request_path))
      metadata
    end

    # Render this template
    # @param [Hash] opts
    # @param [Hash] locs
    # @return [String]
    def render(opts={}, locs={}, &block)
      puts "== Render Start: #{source_file}" if app.logging?
      
      md   = metadata.dup
      opts = options.deep_merge(md[:options]).deep_merge(opts)
      locs = locals.deep_merge(md[:locals]).deep_merge(locs)
      
      # Forward remaining data to helpers
      if md.has_key?(:page)
        app.data.store("page", md[:page])
      end
      
      md[:blocks].flatten.compact.each do |block|
        app.instance_eval(&block)
      end
      
      app.instance_eval(&block) if block_given?
      result = app.render_template(source_file, locs, opts)
      
      puts "== Render End: #{source_file}" if app.logging?
      result
    end
  end
end
