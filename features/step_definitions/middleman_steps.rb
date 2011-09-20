Given /^a clean server$/ do
  @server = Middleman.server
  @server.set :show_exceptions, false
end

Given /^"([^\"]*)" feature is "([^\"]*)"$/ do |feature, state|
  @server = Middleman.server
  @server.set :show_exceptions, false
  
  if state == "enabled"
    @server.activate(feature.to_sym)
  end  
  
  @server.set :environment, @current_env || :development
end

Given /^"([^\"]*)" is set to "([^\"]*)"$/ do |variable, value|
  @server ||= Middleman.server
  @server.set :show_exceptions, false
  @server.set variable.to_sym, value
end

Given /^current environment is "([^\"]*)"$/ do |env|
  @current_env = env.to_sym
end

Given /^the Server is running at "([^\"]*)"$/ do |app_path|
  @server ||= Middleman.server
  @server.set :show_exceptions, false
  root = File.dirname(File.dirname(File.dirname(__FILE__)))
  @server.set :root, File.join(root, "fixtures", app_path)
  @browser = Rack::Test::Session.new(Rack::MockSession.new(@server.new))
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