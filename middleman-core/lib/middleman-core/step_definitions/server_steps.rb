# encoding: UTF-8

require "rack/test"
require "middleman-core/rack/controller"

Given /^a clean server$/ do
  @initialize_commands = []
end

Given /^"([^\"]*)" feature is "([^\"]*)"$/ do |feature, state|
  @initialize_commands ||= []

  if state == "enabled"
    @initialize_commands << lambda { activate(feature.to_sym) }
  end
end

Given /^"([^\"]*)" feature is "enabled" with "([^\"]*)"$/ do |feature, options_str|
  @initialize_commands ||= []

  options = eval("{#{options_str}}")

  @initialize_commands << lambda { activate(feature.to_sym, options) }
end

Given /^the File Watcher is running$/ do
  @server_options ||= {}
  @server_options[:watcher] = true
  @server_options[:force_polling] = true
end

Given /^"([^\"]*)" is set to "([^\"]*)"$/ do |variable, value|
  @initialize_commands ||= []
  @initialize_commands << lambda { set(variable.to_sym, value) }
end

Given /^current environment is "([^\"]*)"$/ do |env|
  @current_env = env.to_sym
end

Given /^the Server is running$/ do
  root_dir = File.expand_path(current_dir)

  if File.exists?(File.join(root_dir, "source"))
    ENV["MM_SOURCE"] = "source"
  else
    ENV["MM_SOURCE"] = ""
  end

  ENV["MM_ROOT"] = root_dir

  server_options = @server_options || {}
  server_options[:root] = root_dir
  initialize_commands = @initialize_commands || []

  @app_rack = ::Middleman::Rack::Controller.new(server_options) do
    set :environment, @current_env || :development
    set :show_exceptions, false
    initialize_commands.each do |p|
      instance_exec(&p)
    end
  end
  
  @browser = ::Rack::Test::Session.new(::Rack::MockSession.new(@app_rack))
end

Given /^the Server is running at "([^\"]*)"$/ do |app_path|
  step %Q{a fixture app "#{app_path}"}
  step %Q{the Server is running}
end

When /^I go to "([^\"]*)"$/ do |url|
  @browser.get(URI.escape(url))
end

Then /^going to "([^\"]*)" should not raise an exception$/ do |url|
  lambda { @browser.get(URI.escape(url)) }.should_not raise_exception
end

Then /^I should see "([^\"]*)"$/ do |expected|
  @browser.last_response.body.should include(expected)
end

Then /^I should see '([^\']*)'$/ do |expected|
  @browser.last_response.body.should include(expected)
end

Then /^I should see:$/ do |expected|
  @browser.last_response.body.should include(expected)
end

Then /^I should not see "([^\"]*)"$/ do |expected|
  @browser.last_response.body.should_not include(expected)
end

Then /^I should see "([^\"]*)" lines$/ do |lines|
  @browser.last_response.body.chomp.split($/).length.should == lines.to_i
end
