# Proxy ignored.html, which should ignore itself through a frontmatter
page 'proxied.html', :proxy => 'ignored.html'
page 'override_layout.html', :layout => :alternate
page 'page_mentioned.html'

ignore '*.frontmatter'

# Reads neighbor for every file on every refresh.
# TODO: Optimize
sitemap.provides_metadata do |file|
  neighbor = "#{file}.frontmatter"
  if File.exists?(neighbor)
    frontmatter = Middleman::CoreExtensions::FrontMatter.frontmatter_and_content(app, neighbor).first
    Middleman::CoreExtensions::FrontMatter.frontmatter_to_metadata(frontmatter)
  else
    {}
  end
end
