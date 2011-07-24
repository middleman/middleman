Given /^page "([^\"]*)" has layout "([^\"]*)"$/ do |url, layout|
  @server ||= Middleman.server
  @server.set :root, File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "fixtures", "test-app")
  @server.page(url, :layout => layout.to_sym)
end

Given /^"([^\"]*)" with_layout block has layout "([^\"]*)"$/ do |url, layout|
  @server ||= Middleman.server
  @server.set :root, File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "fixtures", "test-app")
  @server.with_layout(layout.to_sym) do
    page(url)
  end
end