Given /^I am using an asset host$/ do
  Middleman::Server.enable :asset_host
  Middleman::Server.set :asset_host do |asset|
    "http://assets%d.example.com" % (asset.hash % 4)
  end
  @browser = Rack::Test::Session.new(Rack::MockSession.new(Middleman::Server.new))
end