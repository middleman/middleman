configure :build do
  # Minify Javascript on build
  activate :minify_javascript
  activate :asset_hash
end
