require 'set'

# Directory Indexes extension
class Middleman::Extensions::DirectoryIndexes < ::Middleman::Extension
  # This should run after most other sitemap manipulators so that it
  # gets a chance to modify any new resources that get added.
  self.resource_list_manipulator_priority = 100

  EXTENSIONS = Set.new %w[.htm .html .php .xhtml]

  # Update the main sitemap resource list
  # @return Array<Middleman::Sitemap::Resource>
  Contract ResourceList => ResourceList
  def manipulate_resource_list(resources)
    index_file = app.config[:index_file]
    new_index_path = "/#{index_file}"

    resources.each do |resource|
      # Check if it would be pointless to reroute
      next unless EXTENSIONS.include?(resource.ext)

      next if resource.destination_path == index_file ||
              resource.destination_path.end_with?(new_index_path)

      # Check if file metadata (options set by "page" in config.rb or frontmatter) turns directory_index off
      next if resource.options[:directory_index] == false

      EXTENSIONS.each do |ext|
        resource.destination_path = resource.destination_path.chomp(ext)
      end

      resource.destination_path += new_index_path
    end
  end
end
