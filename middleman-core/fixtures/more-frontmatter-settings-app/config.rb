# frozen_string_literal: true

activate :directory_indexes

# Proxy ignored.html, which should ignore itself through a frontmatter
proxy 'proxied.html', 'ignored.html'
