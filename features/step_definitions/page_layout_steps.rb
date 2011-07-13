Given /^page "([^\"]*)" has layout "([^\"]*)"$/ do |url, layout|
  sandbox_server = Middleman.server do
    set :root, File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "fixtures", "test-app")
    page(url, :layout => layout.to_sym)
  end
  @browser = Rack::Test::Session.new(Rack::MockSession.new(sandbox_server.new))
end

Given /^"([^\"]*)" with_layout block has layout "([^\"]*)"$/ do |url, layout|
  sandbox_server = Middleman.server do
    set :root, File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "fixtures", "test-app")
    with_layout(layout.to_sym) do
      page(url)
    end
  end
  @browser = Rack::Test::Session.new(Rack::MockSession.new(sandbox_server.new))
end