# Directory Indexes extension
class Middleman::Extensions::DirectoryIndexes < ::Middleman::Extension
  # This should run after most other sitemap manipulators so that it
  # gets a chance to modify any new resources that get added.
  self.resource_list_manipulator_priority = 100

  # Update the main sitemap resource list
  # @return [void]
  def manipulate_resource_list(resources)
    index_file = app.config[:index_file]
    new_index_path = "/#{index_file}"

    resources.each do |resource|
      # Check if it would be pointless to reroute
      next if resource.destination_path == index_file ||
              resource.destination_path.end_with?(new_index_path) ||
              File.extname(index_file) != resource.ext

      # Check if frontmatter turns directory_index off
      next if resource.raw_data[:directory_index] == false

      # Check if file metadata (options set by "page" in config.rb) turns directory_index off
      next if resource.render_options[:directory_index] == false

      resource.destination_path = resource.destination_path.chomp(File.extname(index_file)) + new_index_path
    end
  end
end
