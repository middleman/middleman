module Middleman::Sitemap

  class Template
    attr_accessor :page, :options, :locals, :blocks#, :dependencies
  
    def initialize(page)
      @page    = page
      @options = {}
      @locals  = {}
      @blocks  = []
    end
  
    def path
      page.path
    end
    
    def source_file
      page.source_file
    end
    
    def store
      page.store
    end
    
    def app
      store.app
    end
    
    def ext
      page.ext
    end

    def metadata
      app.cache.fetch(:metadata, source_file) do
        metadata = { :options => {}, :locals => {} }
        app.provides_metadata.each do |callback, matcher|
          next if !matcher.nil? && !source_file.match(matcher)
          result = app.instance_exec(source_file, &callback)
          metadata = metadata.deep_merge(result)
        end
        metadata
      end
    end

    def render(opts={}, locs={}, &block)
      opts = options.deep_merge(metadata[:options]).deep_merge(opts)
      locs = locals.deep_merge(metadata[:locals]).deep_merge(locs)
      
      blocks.compact.each do |block|
        app.instance_eval(&block)
      end
      
      app.instance_eval(&block) if block_given?
      app.render_template(source_file, locs, opts)
    end
  end
end