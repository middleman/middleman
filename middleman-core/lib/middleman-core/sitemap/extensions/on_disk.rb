require 'set'

module Middleman::Sitemap::Extensions
  class OnDisk

    attr_accessor :sitemap
    attr_accessor :waiting_for_ready

    def initialize(sitemap)
      @sitemap = sitemap
      @app     = @sitemap.app
      
      @file_paths_on_disk = Set.new

      scoped_self = self
      @waiting_for_ready = true
      
      # Register file change callback
      @app.files.changed do |file|
        scoped_self.touch_file(file, !scoped_self.waiting_for_ready)
      end
      
      # Register file delete callback
      @app.files.deleted do |file|
        scoped_self.remove_file(file, !scoped_self.waiting_for_ready)
      end
      
      @app.ready do
        scoped_self.waiting_for_ready = false
        scoped_self.sitemap.rebuild_resource_list!(:on_disk_ready)
      end
    end

    # Update or add an on-disk file path
    # @param [String] file
    # @return [Boolean]
    def touch_file(file, rebuild=true)
      return false if file == @app.source_dir || File.directory?(file)

      path = file_to_path(file)
      return false unless path

      ignored = @app.ignored_sitemap_matchers.any? do |name, callback|
        callback.call(file, path)
      end

      @file_paths_on_disk << file unless ignored

      # Rebuild the sitemap any time a file is touched
      # in case one of the other manipulators
      # (like asset_hash) cares about the contents of this file,
      # whether or not it belongs in the sitemap (like a partial)
      @sitemap.rebuild_resource_list!(:touched_file) if rebuild
    end
    
    # Remove a file from the store
    # @param [String] file
    # @return [void]
    def remove_file(file, rebuild=true)
      if @file_paths_on_disk.delete?(file)
        @sitemap.rebuild_resource_list!(:removed_file) if rebuild
      end
    end
   
    # Update the main sitemap resource list
    # @return [void]
    def manipulate_resource_list(resources)
      resources + @file_paths_on_disk.map do |file|
        ::Middleman::Sitemap::Resource.new(
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
