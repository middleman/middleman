# Directory Indexes extension
class Middleman::Extensions::DirectoryIndexes < ::Middleman::Extension
  # This should run after most other sitemap manipulators so that it
  # gets a chance to modify any new resources that get added.
  self.resource_list_manipulator_priority = 100

  Contract IsA['Middleman::Sitemap::ResourceListContainer'] => Any
  def manipulate_resource_list_container!(resource_list)
    index_file = app.config[:index_file]
    new_index_path = "/#{index_file}"

    extensions = %w[.htm .html .php .xhtml]

    resource_list.by_extensions(extensions).each do |resource|
      # Check if it would be pointless to reroute
      next if resource.destination_path == index_file ||
              resource.destination_path.end_with?(new_index_path)

      # Check if file metadata (options set by "page" in config.rb or frontmatter) turns directory_index off
      next if resource.options[:directory_index] == false

      resource_list.update!(resource) do
        extensions.each do |ext|
          resource.destination_path = resource.destination_path.chomp(ext)
        end

        resource.destination_path += new_index_path
      end
    end
  end
end
