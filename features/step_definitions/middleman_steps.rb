Given /^"([^\"]*)" feature is "([^\"]*)"$/ do |feature, state|
  enable_or_disable = (state == "enabled") ? :enable : :disable
  Middleman::Base.send(enable_or_disable, feature.to_sym)
  @browser = Rack::Test::Session.new(Rack::MockSession.new(Middleman::Base.new))
end

Given /^generated directory at "([^\"]*)"$/ do |dirname|
  target = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "spec", "fixtures", dirname)
  init_cmd = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "bin", "mm-init")
  `cd #{File.dirname(target)} && #{init_cmd} #{File.basename(target)}`
end

When /^I go to "([^\"]*)"$/ do |url|
  @browser.get(url)
end

Then /^I should see "([^\"]*)"$/ do |expected|
  @browser.last_response.body.should include(expected)
end

Then /^I should not see "([^\"]*)"$/ do |expected|
  @browser.last_response.body.should_not include(expected)
end

Then /^I should see "([^\"]*)" lines$/ do |lines|
  @browser.last_response.body.chomp.split($/).length.should == lines.to_i
end