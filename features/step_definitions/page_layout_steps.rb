Given /^page "([^\"]*)" has layout "([^\"]*)"$/ do |url, layout|
  Middleman::Base.set :root, File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "spec", "fixtures", "sample")
  Middleman::Base.page(url, :layout => layout.to_sym)
  @browser = Rack::Test::Session.new(Rack::MockSession.new(Middleman::Base.new))
end

Given /^"([^\"]*)" with_layout block has layout "([^\"]*)"$/ do |url, layout|
  Middleman::Base.set :root, File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "spec", "fixtures", "sample")
  Middleman::Base.with_layout(:layout => layout.to_sym) do
    page(url)
  end
  @browser = Rack::Test::Session.new(Rack::MockSession.new(Middleman::Base.new))
end