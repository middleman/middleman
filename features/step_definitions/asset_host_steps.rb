Given /^I am using an asset host$/ do
  @server ||= Middleman.server
  @server.activate :asset_host
  @server.set :asset_host do |asset|
    "http://assets%d.example.com" % (asset.hash % 4)
  end
end