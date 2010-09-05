Given /^I am using an asset host$/ do
  Middleman::Base.enable :asset_host
  Middleman::Base.set :asset_host do |asset|
    "http://assets%d.example.com" % (asset.hash % 4)
  end
  @browser = Rack::Test::Session.new(Rack::MockSession.new(Middleman::Base.new))
end