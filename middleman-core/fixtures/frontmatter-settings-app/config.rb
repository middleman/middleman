# Proxy ignored.html, which should ignore itself through a frontmatter
proxy 'proxied.html', 'ignored.html'
page 'override_layout.html', layout: :alternate
page 'page_mentioned.html'
