# Extensions namespace
module Middleman
  module Extensions

    # Directory Indexes extension
    class DirectoryIndexes < ::Middleman::Extension
    
      # Update the main sitemap resource list
      # @return [void]
      def manipulate_resource_list(resources)
        index_file     = app.index_file
        ext            = File.extname(index_file)
        new_index_path = "/#{index_file}"
    
        resources.each do |resource|
          # Check if it would be pointless to reroute
          next if resource.path == index_file ||
                  resource.path.end_with?(new_index_path) ||
                  File.extname(index_file) != resource.ext
      
          # Check if frontmatter turns directory_index off
          d = resource.data
          next if d && d["directory_index"] == false
  
          # Check if file metadata (options set by "page" in config.rb) turns directory_index off
          if resource.metadata[:options] && resource.metadata[:options][:directory_index] == false
            next
          end

      
          directory_path = resource.destination_path.chomp(ext)
          resource.destination_path = directory_path + new_index_path
        end
      end
    end
  end
end
