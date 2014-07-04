ignore '*.frontmatter'

# Reads neighbor for every file on every refresh.
# TODO: Optimize
class NeighborFrontmatter < ::Middleman::Extension
  self.resource_list_manipulator_priority = 81

  def manipulate_resource_list(resources)
    resources.each do |resource|
      next unless resource.source_file

      neighbor = "#{resource.source_file}.frontmatter"
      if File.exists?(neighbor)
        fmdata = app.extensions[:front_matter].frontmatter_and_content(neighbor).first
        opts = fmdata.extract!(:layout, :layout_engine, :renderer_options, :directory_index, :content_type)
        opts[:renderer_options].symbolize_keys! if opts.key?(:renderer_options)
        ignored = fmdata.delete(:ignored)
        resource.add_metadata options: opts, page: fmdata
        resource.ignore! if ignored == true && !resource.proxy?
      end
    end
  end
end

Middleman::Extensions.register :neighbor_frontmatter, NeighborFrontmatter unless Middleman::Extensions.registered.include? :neighbor_frontmatter

activate :neighbor_frontmatter
