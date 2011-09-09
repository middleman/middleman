Given /^I am using an asset host$/ do
  @server ||= Middleman.server
  @server.set :show_exceptions, false
  @server.activate :asset_host
  @server.set :asset_host do |asset|
    "http://assets%d.example.com" % (asset.hash % 4)
  end
end