# Sitemap namespace
module Middleman::Sitemap
  
  # The Store class
  #
  # The Store manages a collection of Page objects, which represent
  # individual items in the sitemap. Pages are indexed by "source path",
  # which is the path relative to the source directory, minus any template
  # extensions. All "path" parameters used in this class are source paths.
  class Store
    
    # @return [Middleman::Base]
    attr_accessor :app
    
    # Initialize with parent app
    # @param [Middleman::Base] app
    def initialize(app)
      @app = app
      @pages = {}
      @ignored_paths     = []
      @ignored_globs     = []
      @ignored_regexes   = []
      @ignored_callbacks = []
      @reroute_callbacks   = []
    end
    
    # Check to see if we know about a specific path
    # @param [String] path
    # @return [Boolean]
    def exists?(path)
      @pages.has_key?(normalize_path(path))
    end
    
    # Ignore a path or add an ignore callback
    # @param [String, Regexp] path, path glob expression, or path regex
    # @return [void]
    def ignore(path=nil, &block)
      if !path.nil? && path.include?("*")
        path_clean = normalize_path(path)
        @ignored_globs << path_clean unless @ignored_globs.include?(path_clean)
      elsif path.is_a? String
        path_clean = normalize_path(path)
        @ignored_paths << path_clean unless @ignored_paths.include?(path_clean)
      elsif path.is_a? Regexp
        @ignored_regexes << path unless @ignored_regexes.include?(path)
      elsif block_given?
        @ignored_callbacks << block
      end
    end
    
    # Add a callback that will be run with each page's destination path
    # and can produce a new destination path or pass through the old one.
    # @return [void]
    def reroute(&block)
      @reroute_callbacks << block if block_given?
    end

    # The list of reroute callbacks
    # @return [Array<Proc>]
    def reroute_callbacks
      @reroute_callbacks
    end

    # Setup a proxy from a path to a target
    # @param [String] path
    # @param [String] target
    # @return [void]
    def proxy(path, target)
      page(path).proxy_to(normalize_path(target))
      app.cache.remove(:proxied_paths)
    end
    
    # Get a page instance for a given path
    # @param [String] path
    # @return [Middleman::Sitemap::Page]
    def page(path)
      path = normalize_path(path)
      @pages.fetch(path) { @pages[path] = ::Middleman::Sitemap::Page.new(self, path) }
    end
    
    # Loop over known pages
    # @yield [path, page]
    # @return [void]
    def each
      @pages.each do |k, v|
        yield k, v
      end
    end
    
    # Get all known paths
    # @return [Array<String>]
    def all_paths
      @pages.keys
    end
    
    # Whether a path is ignored
    # @param [String] path
    # @return [Boolean]
    def ignored?(path)
      path_clean = normalize_path(path)
      
      return true if @ignored_paths.include?(path_clean)
      return true if @ignored_globs.any? { |g| File.fnmatch(g, path_clean) }
      return true if @ignored_regexes.any? { |r| r.match(path_clean) }
      return true if @ignored_callbacks.any? { |b| b.call(path_clean) }

      # TODO: We should also check ignored_sitemap_matchers here

      false
    end
    
    # Get a list of ignored paths
    # @return [Array<String>]
    def ignored_paths
      @pages.values.select(&:ignored?).map(&:path)
    end
    
    # Whether the given path is generic
    # @param [String] path
    # @return [Boolean]
    def generic?(path)
      generic_paths.include?(normalize_path(path))
    end
    
    # Get a list of generic paths
    # @return [Array<String>]
    def generic_paths
      app.cache.fetch :generic_paths do
        @pages.values.select(&:generic?).map(&:path)
      end
    end
    
    # Whether the given path is proxied
    # @param [String] path
    # @return [Boolean]
    def proxied?(path)
      proxied_paths.include?(normalize_path(path))
    end
    
    # Get a list of proxied paths
    # @return [Array<String>]
    def proxied_paths
      app.cache.fetch :proxied_paths do
        @pages.values.select(&:proxy?).map(&:path)
      end
    end
    
    # Remove a file from the store
    # @param [String] file
    # @return [void]
    def remove_file(file)
      path = file_to_path(file)
      return false unless path
      
      path = normalize_path(path)
      if @pages.has_key?(path)
        page(path).delete()
        @pages.delete(path)
      end
    end
    
    # Get the URL path for an on-disk file
    # @param [String] file
    # @return [String]
    def file_to_path(file)
      file = File.expand_path(file, @app.root)
      
      prefix = @app.source_dir.sub(/\/$/, "") + "/"
      return false unless file.include?(prefix)
      
      path = file.sub(prefix, "")
      path = extensionless_path(path)
      
      path
    end
    
    # Update or add an on-disk file path
    # @param [String] file
    # @return [Boolean]
    def touch_file(file)
      return false if file == @app.source_dir || File.directory?(file)
      
      path = file_to_path(file)
      return false unless path
      
      return false if @app.ignored_sitemap_matchers.any? do |name, callback|
        callback.call(file, path)
      end
          
      # Add generic path
      p = page(path)
      p.source_file = File.expand_path(file, @app.root)
      p.touch
      
      true
    end
    
    # Whether the sitemap should completely ignore a given file/path
    # @param [String] file
    # @param [String] path
    # @return [Boolean]
    def sitemap_should_ignore?(file, path)
      @app.sitemap_ignore.every(&:call)
    end
    
  protected
  
    # Get a path without templating extensions
    # @param [String] file
    # @return [String]
    def extensionless_path(file)
      app.cache.fetch(:extensionless_path, file) do
        path = file.dup

        end_of_the_line = false
        while !end_of_the_line
          if !::Tilt[path].nil?
            path = path.sub(File.extname(path), "")
          else
            end_of_the_line = true
          end
        end

        path
      end
    end

    # Normalize a path to not include a leading slash
    # @param [String] path
    # @return [String]
    def normalize_path(path)
      path.sub(/^\//, "").gsub("%20", " ")
    end
  end
end
