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
      cache.fetch(:metadata, source_file) do
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
     
      content = internal_render(source_file, locs, opts)
      
      if layout_path = fetch_layout(opts)
        content = internal_render(layout_path, locs, opts) { content }
      end
        
      content
    end

  protected
    def self.cache
      @_cache ||= ::Middleman::Cache.new
    end
    
    def cache
      self.class.cache
    end

    def options_for_ext(ext)
      cache.fetch(:options_for_ext, ext) do
        options = {}

        extension_class = ::Tilt[ext]
        ::Tilt.mappings.each do |ext, engines|
          next unless engines.include? extension_class
          engine_options = respond_to?(ext.to_sym) ? send(ext.to_sym) : {}
          options.merge!(engine_options)
        end

        options
      end
    end
    
    def fetch_layout(opts)
      return false if %w(.js .css .txt).include?(ext)
      local_layout = opts.has_key?(:layout) ? opts[:layout] : app.layout
      return false unless local_layout
      
      engine = File.extname(source_file)[1..-1].to_sym
      engine_options = app.respond_to?(engine) ? app.send(engine) : {}

      layout_engine = if opts.has_key?(:layout_engine)
        opts[:layout_engine]
      elsif engine_options.has_key?(:layout_engine)
        engine_options[:layout_engine]
      else
        engine
      end

      layout_path, *etc = resolve_template(local_layout, :preferred_engine => layout_engine)

      if !layout_path
        local_layout = File.join("layouts", local_layout.to_s)
        layout_path, *etc = resolve_template(local_layout, :preferred_engine => layout_engine)
      end

      throw "Could not locate layout: #{local_layout}" unless layout_path
      layout_path
    end
    
    def resolve_template(request_path, options={})
      request_path = request_path.to_s
      cache.fetch(:resolve_template, request_path, options) do
        relative_path = request_path.sub(%r{^/}, "")
        on_disk_path  = File.expand_path(relative_path, app.source_dir)

        preferred_engine = if options.has_key?(:preferred_engine)
          extension_class = ::Tilt[options[:preferred_engine]]
          matched_exts = []

          # TODO: Cache this
          ::Tilt.mappings.each do |ext, engines|
            next unless engines.include? extension_class
            matched_exts << ext
          end

          "{" + matched_exts.join(",") + "}"
        else
          "*"
        end

        path_with_ext = on_disk_path + "." + preferred_engine

        found_path = Dir[path_with_ext].find do |path|
          ::Tilt[path]
        end

        result = if found_path || File.exists?(on_disk_path)
          engine = found_path ? File.extname(found_path)[1..-1].to_sym : nil
          [ found_path || on_disk_path, engine ]
        else
          false
        end

        result
      end
    end
    
    def internal_render(path, locs = {}, opts = {}, &block)
      path = path.to_s

      opts.merge!(options_for_ext(File.extname(path)))

      body = app.cache.fetch(:raw_template, path) do
        File.read(path)
      end

      template = cache.fetch(:compiled_template, options, body) do
        ::Tilt.new(path, 1, options) { body }
      end

      template.render(app, locs, &block)
    end
  end
end