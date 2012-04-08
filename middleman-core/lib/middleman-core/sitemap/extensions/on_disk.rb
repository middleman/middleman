module Middleman::Sitemap::Extensions
  class OnDisk

    attr_accessor :sitemap
    attr_accessor :waiting_for_ready

    def initialize(sitemap)
      @sitemap = sitemap
      @app     = @sitemap.app
      
      @file_paths_on_disk = []

      # Cleanup paths
      static_path   = @app.source_dir.sub(@app.root, "").sub(/^\//, "")
      sitemap_regex = static_path.empty? ? // : (%r{^#{static_path + "/"}})
      
      scoped_self = self
      @waiting_for_ready = true
      
      # Register file change callback
      @app.files.changed sitemap_regex do |file|
        scoped_self.touch_file(file, !scoped_self.waiting_for_ready)
      end
      
      # Register file delete callback
      @app.files.deleted sitemap_regex do |file|
        scoped_self.remove_file(file, !scoped_self.waiting_for_ready)
      end
      
      @app.ready do
        scoped_self.waiting_for_ready = false
        scoped_self.sitemap.rebuild_page_list!(:on_disk_ready)
      end
    end

    # Update or add an on-disk file path
    # @param [String] file
    # @return [Boolean]
    def touch_file(file, rebuild=true)
      return false if file == @app.source_dir || File.directory?(file)
  
      path = file_to_path(file)
      return false unless path
  
      return false if @app.ignored_sitemap_matchers.any? do |name, callback|
        callback.call(file, path)
      end
      
      @file_paths_on_disk << file
      @sitemap.rebuild_page_list!(:added_file) if rebuild
    end
    
    # Remove a file from the store
    # @param [String] file
    # @return [void]
    def remove_file(file, rebuild=true)
      @file_paths_on_disk.delete(file)
      @sitemap.rebuild_page_list!(:removed_file) if rebuild
    end
   
    # Update the main sitemap page list
    # @return [void]
    def manipulate_page_list!
      @sitemap.pages = @file_paths_on_disk.map do |file|
        ::Middleman::Sitemap::Page.new(
          @sitemap, 
          file_to_path(file),
          File.expand_path(file, @app.root)
        )
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
    
    # Get a path without templating extensions
    # @param [String] file
    # @return [String]
    def extensionless_path(file)
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
          if @app.template_extensions.has_key?(input_ext)
            path << ".#{@app.template_extensions[input_ext]}"
          end
        end
      end

      path
    end 
  end
end