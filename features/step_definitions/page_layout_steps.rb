Given /^page "([^\"]*)" has layout "([^\"]*)"$/ do |url, layout|
  @server ||= Middleman.server
  @server.page(url, :layout => layout.to_sym)
end

Given /^"([^\"]*)" with_layout block has layout "([^\"]*)"$/ do |url, layout|
  @server ||= Middleman.server
  @server.with_layout(layout.to_sym) do
    page(url)
  end
end