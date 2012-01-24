# Extensions namespace
module Middleman::Extensions
  
  # Directory Indexes extension
  module DirectoryIndexes
    
    # Setup extension
    class << self
      
      # Once registered
      def registered(app)
        # Include methods
        app.send :include, InstanceMethods
        
        # Before requests
        app.before do
          prefix           = @original_path.sub(/\/$/, "")
          indexed_path     = prefix + "/" + index_file
          extensioned_path = prefix + File.extname(index_file)
          
          is_ignored       = false
          fm_ignored       = false
          
          # If the sitemap knows about the path
          if sitemap.exists?(@original_path)
            # Inspect frontmatter
            d = sitemap.page(@original_path).data
            
            # Allow the frontmatter to ignore a directory index
            if !d.nil? && d.has_key?("directory_index") && d["directory_index"] == false
              fm_ignored = true
            else
              next
            end
          else
            # Otherwise check this extension for list of ignored indexes
            is_ignored = ignored_directory_indexes.include?(extensioned_path)
          end

          # If we're going to remap to a directory index
          if !sitemap.exists?(indexed_path) && !is_ignored && !fm_ignored
            parts         = @original_path.split("/")
            last_part     = parts.last
            last_part_ext = File.extname(last_part)
        
            # Change the request
            if last_part_ext.blank?
              # This is a folder, redirect to index
              @request_path = extensioned_path
            end
          end
        end
      
        # Basically does the same as above, but in build mode
        app.build_reroute do |destination, request_path|
          index_ext      = File.extname(index_file)
          new_index_path = "/#{index_file}"
          frontmatter_ignore = false

          # Check for file and frontmatter
          if sitemap.exists?(request_path)
            p = sitemap.page(request_path)
            d = p.data
            if !d.nil?
              frontmatter_ignore = d.has_key?("directory_index") && d["directory_index"] == false
            end
          end

          # Only reroute if not ignored
          if ignored_directory_indexes.include?(request_path)
            false
          elsif request_path =~ /#{new_index_path}$/
            false
          elsif frontmatter_ignore
            false
          else
            [
              destination.sub(/#{index_ext.gsub(".", "\\.")}$/, new_index_path),
              request_path
            ]
          end
        end
      end
      
      alias :included :registered
    end
  
    # Directory indexes instance methods
    module InstanceMethods
      # A list of pages which will not use directory indexes
      # @return [Array<String>]
      def ignored_directory_indexes
        @_ignored_directory_indexes ||= []
      end
    
      # Override the page helper to accept a :directory_index option
      #
      # @param [String] url
      # @param [Hash] options
      # @return [void]
      def page(url, options={}, &block)
        if options.has_key?(:directory_index) && !options["directory_index"]
          ignored_directory_indexes << url
        else
          super
        end
      end
    end
  end
  
  # Register the extension
  register :directory_indexes, DirectoryIndexes
end