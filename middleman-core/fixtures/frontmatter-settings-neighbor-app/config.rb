# Proxy ignored.html, which should ignore itself through a frontmatter
proxy 'proxied.html', 'ignored.html'
proxy 'proxied_with_frontmatter.html', 'ignored.html'
page 'override_layout.html', layout: :alternate
page 'page_mentioned.html'

ignore '*.frontmatter'

# Reads neighbor for every file on every refresh.
class NeighborFrontmatter < ::Middleman::Extension
  self.resource_list_manipulator_priority = 81

  def manipulate_resource_list(resources)
    resources.each do |resource|
      next unless resource.file_descriptor
      next if resource.file_descriptor[:relative_path].extname == '.frontmatter'

      [
        "#{resource.url.sub(/^\//, '')}.frontmatter",
        "#{resource.file_descriptor[:relative_path]}.frontmatter"
      ].each do |n|
        file = app.files.find(:source, n)
        apply_neighbor_data(resource, file) if file
      end
    end
  end

  def apply_neighbor_data(resource, file)
    fmdata = ::Middleman::Util::Data.parse(file, app.config[:frontmatter_delims], :yaml).first
    opts = fmdata.extract!(:layout, :layout_engine, :renderer_options, :directory_index, :content_type)
    opts[:renderer_options].symbolize_keys! if opts.key?(:renderer_options)
    ignored = fmdata.delete(:ignored)
    resource.add_metadata options: opts, page: fmdata
    resource.ignore! if ignored == true && !resource.is_a?(::Middleman::Sitemap::ProxyResource)
  end
end

Middleman::Extensions.register :neighbor_frontmatter, NeighborFrontmatter unless Middleman::Extensions.registered.include? :neighbor_frontmatter

activate :neighbor_frontmatter
