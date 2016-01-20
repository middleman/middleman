ignore '*.frontmatter'

# Reads neighbor for every file on every refresh.
# TODO: Optimize
class NeighborFrontmatter < ::Middleman::Extension
  self.resource_list_manipulator_priority = 81

  def manipulate_resource_list(resources)
    resources.each do |resource|
      next unless resource.file_descriptor

      neighbor = "#{resource.file_descriptor[:relative_path]}.frontmatter"

      file = app.files.find(:source, neighbor)

      next unless file

      fmdata = ::Middleman::Util::Data.parse(file, app.config[:frontmatter_delims], :yaml).first
      opts = fmdata.extract!(:layout, :layout_engine, :renderer_options, :directory_index, :content_type)
      opts[:renderer_options].symbolize_keys! if opts.key?(:renderer_options)
      ignored = fmdata.delete(:ignored)
      resource.add_metadata options: opts, page: fmdata
      resource.ignore! if ignored == true && !resource.is_a?(::Middleman::Sitemap::ProxyResource)
    end
  end
end

Middleman::Extensions.register :neighbor_frontmatter, NeighborFrontmatter unless Middleman::Extensions.registered.include? :neighbor_frontmatter

activate :neighbor_frontmatter
