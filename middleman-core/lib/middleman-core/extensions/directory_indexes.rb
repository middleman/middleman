require 'set'

# Directory Indexes extension
class Middleman::Extensions::DirectoryIndexes < ::Middleman::Extension
  # This should run after most other sitemap manipulators so that it
  # gets a chance to modify any new resources that get added.
  self.resource_list_manipulator_priority = 100

  EXTENSIONS = Set.new %w[.htm .html .php .xhtml]

  Contract IsA['Middleman::Sitemap::ResourceListContainer'] => Any
  def manipulate_resource_list_container!(resource_list)
    index_file = app.config[:index_file]
    new_index_path = "/#{index_file}"

    resource_list.by_extensions(EXTENSIONS).each do |resource|
      next if resource.destination_path == index_file ||
              resource.destination_path.end_with?(new_index_path)

      # Check if file metadata (options set by "page" in config.rb or frontmatter) turns directory_index off
      next if resource.options[:directory_index] == false

      resource_list.update!(resource, :destination_path) do
        EXTENSIONS.each do |ext|
          resource.destination_path = resource.destination_path.chomp(ext)
        end

        resource.destination_path += new_index_path
      end
    end
  end
end
