Given /^page "([^\"]*)" has layout "([^\"]*)"$/ do |url, layout|
  Middleman::Server.set :root, File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "spec", "fixtures", "sample")
  Middleman::Server.page(url, :layout => layout.to_sym)
  @browser = Rack::Test::Session.new(Rack::MockSession.new(Middleman::Server.new))
end

Given /^"([^\"]*)" with_layout block has layout "([^\"]*)"$/ do |url, layout|
  Middleman::Server.set :root, File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "spec", "fixtures", "sample")
  Middleman::Server.with_layout(:layout => layout.to_sym) do
    page(url)
  end
  @browser = Rack::Test::Session.new(Rack::MockSession.new(Middleman::Server.new))
end