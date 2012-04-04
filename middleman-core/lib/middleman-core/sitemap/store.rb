require "middleware"

# Final middleware returns itself
# Works around a bug in the `Middleware` library where this returns nil
::Middleware::Runner.const_set :EMPTY_MIDDLEWARE, lambda { |env| env }

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
    attr_accessor :file_paths_on_disk
    attr_accessor :ignored_callbacks
    attr_accessor :proxy_paths
    
    # Initialize with parent app
    # @param [Middleman::Base] app
    def initialize(app)
      @app = app
      @pages = {}
      @file_paths_on_disk = []
      @proxy_paths        = {}
      @ignored_callbacks  = []
      @reroute_callbacks  = []
      
      @_all_paths_stack = ::Middleware::Builder.new
      @_all_paths_stack.use FilesOnDisk, self
      @_all_paths_stack.use Proxies, self
      @_all_paths_stack.use Ignores, self
      
      all_paths
    end
    
    # def page_details_stack
    #   @_page_details_stack ||= ::Middleware::Builder.new
    # end

    def all_paths
      @_all_paths ||= begin
        $stderr.puts "Entering stack!"
        @_all_paths_stack.call()
      end
    end
    
    def clear_all_paths!
      @_all_paths = nil
      all_paths
    end
      
    # A list of all pages
    # @return [Array<Middleman::Sitemap::Page>]
    def pages
      all_paths.map { |path| page(path) }
    end
    
    # def internal_pages; @pages; end

    # Check to see if we know about a specific path
    # @param [String] path
    # @return [Boolean]
    def exists?(path)
      @_all_paths && @_all_paths.include?(normalize_path(path))
    end
    
    # Ignore a path or add an ignore callback
    # @param [String, Regexp] path, path glob expression, or path regex
    # @return [void]
    def ignore(path=nil, &block)
      if path.is_a? Regexp
        @ignored_callbacks << Proc.new {|p| p =~ path }
      elsif path.is_a? String
        path_clean = normalize_path(path)
        if path_clean.include?("*") # It's a glob
          @ignored_callbacks << Proc.new {|p| File.fnmatch(path_clean, p) }
        else
          @ignored_callbacks << Proc.new {|p| p == path_clean }
        end
      elsif block_given?
        @ignored_callbacks << block
      end
      
      clear_all_paths!
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
      add(path).proxy_to(normalize_path(target))

      self.proxy_paths[normalize_path(path)] = normalize_path(target)
      clear_all_paths!
    end

    # Add a new page to the sitemap
    # @param [String] path
    # @return [Middleman::Sitemap::Page]
    def add(path)
      path = normalize_path(path)
      @pages.fetch(path) { @pages[path] = ::Middleman::Sitemap::Page.new(self, path) }
    end
    
    # Get a page instance for a given path, or nil if that page doesn't exist in the sitemap
    # @param [String] path
    # @return [Middleman::Sitemap::Page]
    def page(path)
      path = normalize_path(path)
      @pages[path]
    end

    # Find a page given its destination path
    # @param [String] The destination (output) path of a page.
    # @return [Middleman::Sitemap::Page]
    def page_by_destination(destination_path)
      destination_path = normalize_path(destination_path)
      pages.find do |p|
        p.destination_path == destination_path ||
        p.destination_path == destination_path.sub("/#{@app.index_file}", "")
      end
    end
    
    # Whether a path is ignored
    # @param [String] path
    # @return [Boolean]
    def ignored?(path)
      path_clean = normalize_path(path)
      @ignored_callbacks.any? { |b| b.call(path_clean) }
    end
    
    # Remove a file from the store
    # @param [String] file
    # @return [void]
    def remove_file(file)
      self.file_paths_on_disk.delete(file)
      clear_all_paths!
    
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
      extensionless_path(path)
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
          
      self.file_paths_on_disk << file
      clear_all_paths!
      
      # Add generic path
      p = add(path)
      p.source_file = File.expand_path(file, @app.root)
      p.touch
      
      true
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

        # If there is no extension, look for one
        if File.extname(path).empty?
          input_ext = File.extname(file)
          
          if !input_ext.empty?
            input_ext = input_ext.split(".").last.to_sym
            if app.template_extensions.has_key?(input_ext)
              path << ".#{app.template_extensions[input_ext]}"
            end
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

  class Middleware
    def initialize(app, sitemap)
      @app     = app
      @sitemap = sitemap
    end
  end
  
  class Proxies < Middleware
    def call(env)
      paths = env.concat(@sitemap.proxy_paths.keys)
      
      $stderr.puts "Proxy: #{paths.length}"
      res = @app.call(paths)
      $stderr.puts "Res:"
      $stderr.puts res.inspect
      res
    end
  end
  
  class Ignores < Middleware
    def call(env)
      paths = env.reject do |path|
        @sitemap.ignored?(path)
      end
      
      $stderr.puts "Ignore: #{paths.length}"
      @app.call(paths)
    end
  end
  
  class FilesOnDisk < Middleware
    def call(env)
      # Ignore template paths
      paths = @sitemap.file_paths_on_disk.reject do |file_path|
        relative_source = File.join(@sitemap.app.root, file_path).sub(@sitemap.app.source_dir, '')
        @sitemap.ignored?(relative_source)
      end.map do |file|
        @sitemap.file_to_path(file)
      end
      
      $stderr.puts "Files on: #{paths.length}"
      @app.call(paths)
    end
  end
end