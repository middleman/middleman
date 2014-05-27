Given /^page "([^\"]*)" has layout "([^\"]*)"$/ do |url, layout|
  @initialize_commands ||= []
  @initialize_commands << lambda {
    page(url, layout: layout.to_sym)
  }
end
