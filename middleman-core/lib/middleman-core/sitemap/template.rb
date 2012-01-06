module Middleman::Sitemap

  class Template
    attr_accessor :page, :options, :locals, :blocks, :request_path
  
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
    
    def touch
      app.cache.remove(:metadata, source_file)
    end
    
    def metadata
      metadata = app.cache.fetch(:metadata, source_file) do
        data = { :options => {}, :locals => {}, :page => {}, :blocks => [] }
        
        app.provides_metadata.each do |callback, matcher|
          next if !matcher.nil? && !source_file.match(matcher)
          result = app.instance_exec(source_file, &callback)
          data = data.deep_merge(result)
        end
        
        data
      end
      
      app.provides_metadata_for_path.each do |callback, matcher|
        if matcher.is_a? Regexp
          next if !self.request_path.match(matcher)
        elsif matcher.is_a? String
          next if "/#{self.request_path}" != matcher
        end
      
        result = app.instance_exec(self.request_path, &callback)
        if result.has_key?(:blocks)
          metadata[:blocks] << result[:blocks]
          result.delete(:blocks)
        end
        metadata = metadata.deep_merge(result)
      end
      
      metadata
    end

    def render(opts={}, locs={}, &block)
      puts "== Render Start: #{source_file}" if app.logging?
      
      md   = metadata.dup
      opts = options.deep_merge(md[:options]).deep_merge(opts)
      locs = locals.deep_merge(md[:locals]).deep_merge(locs)
      
      # Forward remaining data to helpers
      if md.has_key?(:page)
        app.data.store("page", md[:page])
      end
      
      blocks.compact.each do |block|
        app.instance_eval(&block)
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