# encoding: UTF-8

require 'rack/test'

Given /^a clean server$/ do
  @initialize_commands = []
end

Given /^"([^\"]*)" feature is "([^\"]*)"$/ do |feature, state|
  @initialize_commands ||= []

  if state == 'enabled'
    @initialize_commands << lambda { activate(feature.to_sym) }
  end
end

Given /^"([^\"]*)" feature is "enabled" with "([^\"]*)"$/ do |feature, options_str|
  @initialize_commands ||= []

  options = eval("{#{options_str}}")

  @initialize_commands << lambda { activate(feature.to_sym, options) }
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


  if File.exists?(File.join(root_dir, 'source'))
    ENV['MM_SOURCE'] = 'source'
  else
    ENV['MM_SOURCE'] = ''
  end

  ENV['MM_ROOT'] = root_dir

  initialize_commands = @initialize_commands || []
  initialize_commands.unshift lambda {
    set :environment, @current_env || :development
    set :show_exceptions, false
  }

  in_current_dir do
    @server_inst = Middleman::Application.server.inst do
      initialize_commands.each do |p|
        instance_exec(&p)
      end
    end
  end

  app_rack = @server_inst.class.to_rack_app
  @browser = ::Rack::Test::Session.new(::Rack::MockSession.new(app_rack))
end

Given /^the Server is running at "([^\"]*)"$/ do |app_path|
  step %Q{a fixture app "#{app_path}"}
  step %Q{the Server is running}
end

Given /^a template named "([^\"]*)" with:$/ do |name, string|
  step %Q{a file named "source/#{name}" with:}, string
end

When /^I go to "([^\"]*)"$/ do |url|
  in_current_dir do
    @browser.get(URI.encode(url))
  end
end

Then /^going to "([^\"]*)" should not raise an exception$/ do |url|
  in_current_dir do
    expect{ @browser.get(URI.encode(url)) }.to_not raise_exception
  end
end

Then /^the content type should be "([^\"]*)"$/ do |expected|
  in_current_dir do
    expect(@browser.last_response.content_type).to start_with(expected)
  end
end

Then /^I should see "([^\"]*)"$/ do |expected|
  in_current_dir do
    expect(@browser.last_response.body).to include(expected)
  end
end

Then /^I should see '([^\']*)'$/ do |expected|
  in_current_dir do
    expect(@browser.last_response.body).to include(expected)
  end
end

Then /^I should see:$/ do |expected|
  in_current_dir do
    expect(@browser.last_response.body).to include(expected)
  end
end

Then /^I should not see "([^\"]*)"$/ do |expected|
  in_current_dir do
    expect(@browser.last_response.body).to_not include(expected)
  end
end

Then /^I should not see:$/ do |expected|
  in_current_dir do
    expect(@browser.last_response.body).to_not include(expected.chomp)
  end
end

Then /^the status code should be "([^\"]*)"$/ do |expected|
  in_current_dir do
    expect(@browser.last_response.status).to eq expected.to_i
  end
end

Then /^I should see "([^\"]*)" lines$/ do |lines|
  in_current_dir do
    expect(@browser.last_response.body.chomp.split($/).length).to eq(lines.to_i)
  end
end
