require "rack/test"

Given /^a clean server$/ do
  @initialize_commands = []
end

Given /^"([^\"]*)" feature is "([^\"]*)"$/ do |feature, state|
  @initialize_commands ||= []
  
  if state == "enabled"
    @initialize_commands << lambda { activate(feature.to_sym) }
  end
end

Given /^"([^\"]*)" is set to "([^\"]*)"$/ do |variable, value|
  @initialize_commands ||= []
  @initialize_commands << lambda { set(variable.to_sym, value) }
end

Given /^current environment is "([^\"]*)"$/ do |env|
  @current_env = env.to_sym
end

Given /^the Server is running at "([^\"]*)"$/ do |app_path|
  step %Q{a project at "#{app_path}"}
  
  initialize_commands = @initialize_commands || []
  initialize_commands.unshift lambda { 
    set :root, File.join(PROJECT_ROOT_PATH, "fixtures", app_path)
    set :environment, @current_env || :development
  }
  
  @server_inst = Middleman.server.inst do
    initialize_commands.each do |p|
      instance_exec(&p)
    end
  end
  
  app_rack = @server_inst.class.to_rack_app
  @browser = ::Rack::Test::Session.new(::Rack::MockSession.new(app_rack))
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