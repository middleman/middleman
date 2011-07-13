Given /^"([^\"]*)" feature is "([^\"]*)"$/ do |feature, state|
  sandbox_server = Middleman.server do
    if state == "enabled"
      activate(feature.to_sym)
    end
    set :environment, @current_env || :development
  end
  @browser = Rack::Test::Session.new(Rack::MockSession.new(sandbox_server.new))
end

Given /^current environment is "([^\"]*)"$/ do |env|
  @current_env = env.to_sym
end

Given /^the Server is running$/ do
  sandbox_server = Middleman.server
  @browser = Rack::Test::Session.new(Rack::MockSession.new(sandbox_server.new))
end

When /^I go to "([^\"]*)"$/ do |url|
  @browser.get(url)
end

Then /^I should see "([^\"]*)"$/ do |expected|
  @browser.last_response.body.should include(expected)
end

Then /^I should see '([^\']*)'$/ do |expected|
  @browser.last_response.body.should include(expected)
end

Then /^I should not see "([^\"]*)"$/ do |expected|
  @browser.last_response.body.should_not include(expected)
end

Then /^I should see "([^\"]*)" lines$/ do |lines|
  @browser.last_response.body.chomp.split($/).length.should == lines.to_i
end