module Middleman::CoreExtensions::Rendering
  class << self
    def registered(app)
      # Autoload
      require "coffee_script"
      
      app.send :include, InstanceMethods
      
      # Activate custom renderers
      app.register Middleman::Renderers::Haml
      app.register Middleman::Renderers::Sass
      app.register Middleman::Renderers::Markdown
      app.register Middleman::Renderers::ERb
      app.register Middleman::Renderers::Liquid
      
      begin
        require "slim"
      rescue LoadError
      end
    end
    alias :included :registered
  end
  
  class TemplateNotFound < RuntimeError
  end
  
  module InstanceMethods
    def initialize
      super
      
      file_changed %r{^source/} do |file|
        path = File.expand_path(file, root)
        cache.remove(:raw_template, path)
      end
    end
    
    def render_template(path, locs={}, opts={})
      extension = File.extname(path)
      engine = extension[1..-1].to_sym

      @current_engine, engine_was = engine, @current_engine
      @_out_buf, _buf_was = "", @_out_buf
    
      content = render_individual_file(path, locs, opts)
      
      needs_layout = !%w(.js .css .txt).include?(extension)
      
      if needs_layout && layout_path = fetch_layout(engine, opts)
        content = render_individual_file(layout_path, locs, opts) { content }
      end
        
      content
    ensure
      @current_engine = engine_was
      @_out_buf = _buf_was
      @content_blocks = nil
    end
    
    # Sinatra/Padrino render method signature.
    def render(engine, data, options={}, locals={}, &block)
      data = data.to_s

      found_partial = false
      engine        = nil

      if sitemap.exists?(current_path)
        page = sitemap.page(current_path)
        current_dir = File.dirname(page.source_file)
        engine = File.extname(page.source_file)[1..-1].to_sym

        if current_dir != self.source_dir
          relative_dir = File.join(current_dir.sub("#{self.source_dir}/", ""), data)

          found_partial, found_engine = resolve_template(relative_dir, :preferred_engine => engine)

          if !found_partial
            found_partial, found_engine = resolve_template(relative_dir)
          end
        end
      end

      if !found_partial && !engine.nil?
        found_partial, found_engine = resolve_template(data, :preferred_engine => engine)
      end

      if !found_partial
        found_partial, found_engine = resolve_template(data)
      end

      if found_partial
        render_individual_file(found_partial, locals, options, &block)
      else
        raise ::Middleman::CoreExtensions::Rendering::TemplateNotFound, "Could not locate partial: #{data}"
      end
    end

    # @private
    def render_individual_file(path, locs = {}, opts = {}, &block)
      path = path.to_s
      
      body = cache.fetch(:raw_template, path) do
        File.read(path)
      end
      
      extension = File.extname(path)
      options = opts.merge(options_for_ext(extension))
      options[:outvar] ||= '@_out_buf'

      template = cache.fetch(:compiled_template, options, body) do
        ::Tilt.new(path, 1, options) { body }
      end

      template.render(self, locs, &block)
    end
    
    # @private
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
  
    # @private
    def fetch_layout(engine, opts)
      local_layout = opts.has_key?(:layout) ? opts[:layout] : layout
      return false unless local_layout
    
      engine_options = respond_to?(engine) ? send(engine) : {}

      layout_engine = if opts.has_key?(:layout_engine)
        opts[:layout_engine]
      elsif engine_options.has_key?(:layout_engine)
        engine_options[:layout_engine]
      else
        engine
      end

      # Automatic
      if local_layout == :_auto_layout
        # Look for :layout of any extension
        # If found, use it. If not, continue
        locate_layout(:layout, layout_engine) || false
      else
        # Look for specific layout
        # If found, use it. If not, error.
        if layout_path = locate_layout(local_layout, layout_engine)
          layout_path
        else
          raise ::Middleman::CoreExtensions::Rendering::TemplateNotFound, "Could not locate layout: #{local_layout}"
        end
      end
    end
  
    # @private
    def locate_layout(name, preferred_engine=nil)
      layout_path = false
    
      if !preferred_engine.nil?
        # Check root
        layout_path, layout_engine = resolve_template(name, :preferred_engine => preferred_engine)

        # Check layouts folder
        if !layout_path
          layout_path, layout_engine = resolve_template(File.join("layouts", name.to_s), :preferred_engine => preferred_engine)
        end
      end
    
      # Check root, no preference
      if !layout_path
        layout_path, layout_engine = resolve_template(name)
      end
    
      # Check layouts folder, no preference
      if !layout_path
        layout_path, layout_engine = resolve_template(File.join("layouts", name.to_s))
      end
    
      layout_path
    end
  
    def current_engine
      @current_engine ||= nil
    end
    
    # @private
    def resolve_template(request_path, options={})
      request_path = request_path.to_s
      cache.fetch(:resolve_template, request_path, options) do
        relative_path = request_path.sub(%r{^/}, "")
        on_disk_path  = File.expand_path(relative_path, self.source_dir)

        preferred_engine = "*"
      
        if options.has_key?(:preferred_engine)
          extension_class = ::Tilt[options[:preferred_engine]]
          matched_exts = []

          # TODO: Cache this
          ::Tilt.mappings.each do |ext, engines|
            next unless engines.include? extension_class
            matched_exts << ext
          end

          if matched_exts.length > 0
            preferred_engine = "{" + matched_exts.join(",") + "}"
          else
            return false
          end
        end

        path_with_ext = on_disk_path + "." + preferred_engine
        found_path = Dir[path_with_ext].find do |path|
          ::Tilt[path]
        end

        if found_path || File.exists?(on_disk_path)
          engine = found_path ? File.extname(found_path)[1..-1].to_sym : nil
          [ found_path || on_disk_path, engine ]
        else
          false
        end
      end
    end
  end
end