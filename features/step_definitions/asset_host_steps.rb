Given /^I am using an asset host$/ do
  sandbox_server = Middleman.server do
    activate :asset_host
    set :asset_host do |asset|
      "http://assets%d.example.com" % (asset.hash % 4)
    end
  end
  @browser = Rack::Test::Session.new(Rack::MockSession.new(sandbox_server.new))
end