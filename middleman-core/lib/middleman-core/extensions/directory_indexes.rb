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
        
        # TODO: unify these by replacing the "before" thing with a
        # lookup by destination_path

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
            if sitemap.exists?(extensioned_path)
              is_ignored = ignored_directory_indexes.include?(sitemap.page(extensioned_path))
            end
          end

          # If we're going to remap to a directory index
          if !sitemap.exists?(indexed_path) && !is_ignored && !fm_ignored
            parts         = @original_path.split("/")
            last_part     = parts.last || ''
            last_part_ext = File.extname(last_part)
        
            # Change the request
            if last_part_ext.blank?
              # This is a folder, redirect to index
              @request_path = extensioned_path
            end
          end
        end
      
        app.after_configuration do
          # Basically does the same as above, but in build mode
          sitemap.reroute do |destination, page|
            new_index_path = "/#{index_file}"
            frontmatter_ignore = false

            # Check for file and frontmatter
            d = page.data
            if !page.data.nil?
              frontmatter_ignore = d.has_key?("directory_index") && d["directory_index"] == false
            end

            index_ext = File.extname(index_file)

            # Only reroute if not ignored
            request_path = page.request_path
            if ignored_directory_indexes.include? page
              destination
            elsif request_path == index_file || request_path.end_with?(new_index_path)
              destination
            elsif frontmatter_ignore
              destination
            elsif index_ext != File.extname(request_path)
              destination
            else
              destination.chomp(File.extname(index_file)) + new_index_path
            end
          end
        end
      end

      alias :included :registered
    end
  
    module InstanceMethods
      # A list of pages which will not use directory indexes
      # @return [Array<Middleman::Sitemap::Page>]
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
          ignored_directory_indexes << sitemap.page(url)
        else
          super
        end
      end
    end
  end
  
  # Register the extension
  register :directory_indexes, DirectoryIndexes
end
