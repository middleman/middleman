activate :directory_indexes

# Proxy ignored.html, which should ignore itself through a frontmatter
page 'proxied.html', :proxy => 'ignored.html'
