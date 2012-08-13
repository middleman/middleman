set :layout, false

activate :asset_host
set :asset_host do |asset|
  "http://assets%d.example.com" % (asset.hash % 4)
end
