# Shutup Tilt Warnings
# @private
class Tilt::Template
  def warn(*args)
    # Kernel.warn(*args)
  end
end

# Rendering extension
module Middleman::CoreExtensions::Rendering
  
  # Setup extension
  class << self
    
    # Once registered
    def registered(app)
      # Include methods
      app.send :include, InstanceMethods
      
      # Activate custom renderers
      app.register Middleman::Renderers::ERb
    end
    
    alias :included :registered
  end
  
  # Custom error class for handling
  class TemplateNotFound < RuntimeError
  end
  
  # Rendering instance methods
  module InstanceMethods
    
    # Override init to clear cache on file removal
    def initialize
      # Default extension map
      @_template_extensions = {
        
      }
      
      super
      
      static_path = source_dir.sub(self.root, "").sub(/^\//, "")
      render_regex = static_path.empty? ? // : (%r{^#{static_path + "/"}})
      
      self.files.changed render_regex do |file|
        path = File.expand_path(file, self.root)
        self.cache.remove(:raw_template, path)
      end
    end
    
    # Add or overwrite a default template extension
    #
    # @param [Hash] extension_map
    # @return [void]
    def template_extensions(extension_map={})
      @_template_extensions.merge!(extension_map)
    end
    
    # Render a template, with layout, given a path
    #
    # @param [String] path
    # @param [Hash] locs
    # @param [Hash] opts
    # @return [String]
    def render_template(path, locs={}, opts={})
      # Detect the remdering engine from the extension
      extension = File.extname(path)
      engine = extension[1..-1].to_sym

      # Store last engine for later (could be inside nested renders)
      @current_engine, engine_was = engine, @current_engine
      
      # Use a dup of self as a context so that instance variables set within 
      # the template don't persist for other templates.
      context = self.dup

      # Store current locs/opts for later
      @current_locs = locs, @current_opts = opts

      # Keep rendering template until we've used up all extensions. This handles
      # cases like `style.css.sass.erb`
      while ::Tilt[path]
        content = render_individual_file(path, locs, opts, context)
        path = File.basename(path, File.extname(path))
        cache.set([:raw_template, path], content)
      end
      
      # Certain output file types don't use layouts
      needs_layout = !%w(.js .json .css .txt).include?(extension)
      
      # If we need a layout and have a layout, use it
      if needs_layout && layout_path = fetch_layout(engine, opts)
        content = render_individual_file(layout_path, locs, opts, context) { content }
      end
        
      # Return result
      content
    ensure
      # Pop all the saved variables from earlier as we may be returning to a 
      # previous render (layouts, partials, nested layouts).
      @current_engine = engine_was
      @content_blocks = nil
      @current_locs = nil
      @current_opts = nil
    end
    
    # Sinatra/Padrino compatible render method signature referenced by some view
    # helpers. Especially partials.
    #
    # @param [String, Symbol] engine
    # @param [String, Symbol] data
    # @param [Hash] options
    # @return [String]
    def render(engine, data, options={}, &block)
      data = data.to_s

      locals = options[:locals]

      found_partial = false
      engine        = nil

      # If the path is known to the sitemap
      if resource = sitemap.find_resource_by_destination_path(current_path)
        current_dir = File.dirname(resource.source_file)
        engine = File.extname(resource.source_file)[1..-1].to_sym

        # Look for partials relative to the current path
        if current_dir != self.source_dir
          relative_dir = File.join(current_dir.sub("#{self.source_dir}/", ""), data)

          # Try to use the current engine first
          found_partial, found_engine = resolve_template(relative_dir, :preferred_engine => engine)

          # Fall back to any engine available
          if !found_partial
            found_partial, found_engine = resolve_template(relative_dir)
          end
        end
      end
      
      # Look in the root for the partial with the current engine
      if !found_partial && !engine.nil?
        found_partial, found_engine = resolve_template(data, :preferred_engine => engine)
      end

      # Look in the root with any engine
      if !found_partial
        found_partial, found_engine = resolve_template(data)
      end

      # Render the partial if found, otherwide throw exception
      if found_partial
        render_individual_file(found_partial, locals, options, self, &block)
      else
        raise ::Middleman::CoreExtensions::Rendering::TemplateNotFound, "Could not locate partial: #{data}"
      end
    end

    # Render an on-disk file. Used for everything, including layouts.
    #
    # @param [String, Symbol] path
    # @param [Hash] locs
    # @param [Hash] opts
    # @param [Class] context
    # @return [String]
    def render_individual_file(path, locs = {}, opts = {}, context = self, &block)
      path = path.to_s
      
      # Save current buffere for later
      @_out_buf, _buf_was = "", @_out_buf
      
      # Read from disk or cache the contents of the file
      body = cache.fetch(:raw_template, path) do
        File.read(path)
      end
      
      # Merge per-extension options from config
      extension = File.extname(path)
      options = opts.merge(options_for_ext(extension))
      options[:outvar] ||= '@_out_buf'

      # Read compiled template from disk or cache
      template = cache.fetch(:compiled_template, options, body) do
        ::Tilt.new(path, 1, options) { body }
      end

      # Render using Tilt
      template.render(context, locs, &block)
    ensure
      # Reset stored buffer
      @_out_buf = _buf_was
    end
    
    # Get a hash of configuration options for a given file extension, from 
    # config.rb
    #
    # @param [String] ext
    # @return [Hash]
    def options_for_ext(ext)
      # Read options for extension from config/Tilt or cache
      cache.fetch(:options_for_ext, ext) do
        options = {}

        # Find all the engines which handle this extension in tilt. Look for 
        # config variables of that name and merge it
        extension_class = ::Tilt[ext]
        ::Tilt.mappings.each do |ext, engines|
          next unless engines.include? extension_class
          engine_options = respond_to?(ext.to_sym) ? send(ext.to_sym) : {}
          options.merge!(engine_options)
        end

        options
      end
    end
  
    # Find a layout for a given engine
    #
    # @param [Symbol] engine
    # @param [Hash] opts
    # @return [String]
    def fetch_layout(engine, opts)
      # The layout name comes from either the system default or the options
      local_layout = opts.has_key?(:layout) ? opts[:layout] : layout
      return false unless local_layout
    
      # Look for engine-specific options
      engine_options = respond_to?(engine) ? send(engine) : {}

      # The engine for the layout can be set in options, engine_options or passed
      # into this method
      layout_engine = if opts.has_key?(:layout_engine)
        opts[:layout_engine]
      elsif engine_options.has_key?(:layout_engine)
        engine_options[:layout_engine]
      else
        engine
      end

      # Automatic mode
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
  
    # Find a layout on-disk, optionally using a specific engine
    # @param [String] name
    # @param [Symbol] preferred_engine
    # @return [String]
    def locate_layout(name, preferred_engine=nil)
      # Whether we've found the layout
      layout_path = false
      
      # If we prefer a specific engine
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
    
      # Return the path
      layout_path
    end
    
    # Allow layouts to be wrapped in the contents of other layouts
    # @param [String, Symbol] layout_name
    # @return [void]
    def wrap_layout(layout_name, &block)
      content = capture(&block) if block_given?
      layout_path = locate_layout(layout_name, current_engine)
      concat render_individual_file(layout_path, @current_locs || {}, @current_opts || {}, self) { content }
    end
    
    # The currently rendering engine
    # @return [Symbol, nil]
    def current_engine
      @current_engine ||= nil
    end
    
    # Find a template on disk given a output path
    # @param [String] request_path
    # @param [Hash] options
    # @return [Array<String, Symbol>, Boolean]
    def resolve_template(request_path, options={})
      # Find the path by searching or using the cache
      request_path = request_path.to_s
      cache.fetch(:resolve_template, request_path, options) do
        relative_path = request_path.sub(%r{^/}, "")
        on_disk_path  = File.expand_path(relative_path, self.source_dir)

        # By default, any engine will do
        preferred_engine = "*"
      
        # Unless we're specifically looking for a preferred engine
        if options.has_key?(:preferred_engine)
          extension_class = ::Tilt[options[:preferred_engine]]
          matched_exts = []

          # Get a list of extensions for a preferred engine
          # TODO: Cache this
          ::Tilt.mappings.each do |ext, engines|
            next unless engines.include? extension_class
            matched_exts << ext
          end

          # Change the glob to only look for the matched extensions
          if matched_exts.length > 0
            preferred_engine = "{" + matched_exts.join(",") + "}"
          else
            return false
          end
        end

        # Look for files that match
        path_with_ext = on_disk_path + "." + preferred_engine
        found_path = Dir[path_with_ext].find do |path|
          ::Tilt[path]
        end
        
        # If we found one, return it and the found engine
        if found_path || (File.exists?(on_disk_path) && !File.directory?(on_disk_path))
          engine = found_path ? File.extname(found_path)[1..-1].to_sym : nil
          [ found_path || on_disk_path, engine ]
        else
          false
        end
      end
    end
  end
end