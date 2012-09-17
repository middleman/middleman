# Extensions namespace
module Middleman
  module Extensions

    # Directory Indexes extension
    module DirectoryIndexes

      # Setup extension
      class << self

        # Once registered
        def registered(app)
          app.after_configuration do
            sitemap.register_resource_list_manipulator(
              :directory_indexes,
              DirectoryIndexManager.new(self)
            )
          end
        end

        alias :included :registered
      end

      # Central class for managing the directory indexes extension
      class DirectoryIndexManager
        def initialize(app)
          @app = app
        end

        # Update the main sitemap resource list
        # @return [void]
        def manipulate_resource_list(resources)
          index_file = @app.index_file
          new_index_path = "/#{index_file}"

          resources.each do |resource|
            # Check if it would be pointless to reroute
            next if resource.destination_path == index_file ||
                    resource.destination_path.end_with?(new_index_path) ||
                    File.extname(index_file) != resource.ext

            # Check if frontmatter turns directory_index off
            d = resource.data
            next if d && d["directory_index"] == false

            # Check if file metadata (options set by "page" in config.rb) turns directory_index off
            if resource.metadata[:options] && resource.metadata[:options][:directory_index] == false
              next
            end

            resource.destination_path = resource.destination_path.chomp(File.extname(index_file)) + new_index_path
          end
        end
      end
    end
  end
end
