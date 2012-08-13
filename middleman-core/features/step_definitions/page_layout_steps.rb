Given /^page "([^\"]*)" has layout "([^\"]*)"$/ do |url, layout|
  @initialize_commands ||= []
  @initialize_commands << lambda {
    page(url, :layout => layout.to_sym)
  }
end

Given /^"([^\"]*)" with_layout block has layout "([^\"]*)"$/ do |url, layout|
  @initialize_commands ||= []
  @initialize_commands << lambda {
    with_layout(layout.to_sym) do
      page(url)
    end
  }
end
