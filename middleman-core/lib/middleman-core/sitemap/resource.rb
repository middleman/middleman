# Sitemap namespace
module Middleman::Sitemap
  
  # Sitemap Resource class
  class Resource
    include Middleman::Sitemap::Extensions::Traversal
        
    # @return [Middleman::Application]
    attr_reader :app
    
    # @return [Middleman::Sitemap::Store]
    attr_reader :store
    
    # The source path of this resource (relative to the source directory,
    # without template extensions)
    # @return [String]
    attr_reader :path
    
    # Set the on-disk source file for this resource
    # @return [String]
    # attr_reader :source_file
    
    def source_file
      @source_file || get_source_file
    end
    
    # Initialize resource with parent store and URL
    # @param [Middleman::Sitemap::Store] store
    # @param [String] path
    # @param [String] source_file
    def initialize(store, path, source_file=nil)
      @store       = store
      @app         = @store.app
      @path        = path
      @source_file = source_file
      
      @destination_paths = [@path]
    end
    
    # Whether this resource has a template file
    # @return [Boolean]
    def template?
      return false if source_file.nil?
      !::Tilt[source_file].nil?
    end
    
    # Get the metadata for both the current source_file and the current path
    # @return [Hash]
    def metadata
      store.metadata_for_file(source_file).deep_merge(
        store.metadata_for_path(path)
      )
    end
    
    # Get the output/preview URL for this resource
    # @return [String]
    def destination_path
      @destination_paths.last
    end
    
    # Set the output/preview URL for this resource
    # @param [String] path
    # @return [void]
    def destination_path=(path)
      @destination_paths << path
    end
    
    # The template instance
    # @return [Middleman::Sitemap::Template]
    def template
      @_template ||= ::Middleman::Sitemap::Template.new(self)
    end
    
    # Extension of the path (i.e. '.js')
    # @return [String]
    def ext
      File.extname(path)
    end
    
    # Mime type of the path
    # @return [String]
    def mime_type
      app.mime_type ext
    end
    
    # Render this resource
    # @return [String]
    def render(opts={}, locs={}, &block)
      return File.open(source_file).read unless template?
      
      start_time = Time.now
      puts "== Render Start: #{source_file}" if app.logging?

      md   = metadata.dup
      opts = md[:options].deep_merge(opts)
      locs = md[:locals].deep_merge(locs)

      # Forward remaining data to helpers
      if md.has_key?(:page)
        app.data.store("page", md[:page])
      end

      md[:blocks].flatten.compact.each do |block|
        app.instance_eval(&block)
      end

      app.instance_eval(&block) if block_given?
      result = app.render_template(source_file, locs, opts)

      puts "== Render End: #{source_file} (#{(Time.now - start_time).round(2)}s)" if app.logging?
      result
    end
    
    # A path without the directory index - so foo/index.html becomes
    # just foo. Best for linking.
    # @return [String]
    def url
      '/' + destination_path.sub(/#{Regexp.escape(app.index_file)}$/, '')
    end

    # Get the relative path from the source
    # @return [String]
    def relative_path
      source_file ? source_file.sub(app.source_dir, '') : nil
    end
  end
end
