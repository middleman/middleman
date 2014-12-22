# Proxy ignored.html, which should ignore itself through a frontmatter
page 'proxied.html', :proxy => 'ignored.html'
page 'proxied_with_frontmatter.html', :proxy => 'ignored.html'
page 'override_layout.html', :layout => :alternate
page 'page_mentioned.html'
