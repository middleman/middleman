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
        
        app.after_configuration do
          # Register a reroute transform that turns regular paths into indexed paths
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
            path = page.path
            if ignored_directory_indexes.include? page
              destination
            elsif path == index_file || path.end_with?(new_index_path)
              destination
            elsif frontmatter_ignore
              destination
            elsif index_ext != File.extname(path)
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
