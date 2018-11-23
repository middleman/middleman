require 'middleman-core/rack'
require 'rspec/expectations'
require 'capybara/cucumber'

Given /^a clean server$/ do
  @initialize_commands = []
  @activation_commands = []
end

Given /^"([^\"]*)" feature is "([^\"]*)"$/ do |feature, state|
  @activation_commands ||= []

  @activation_commands << -> { activate(feature.to_sym) } if state == 'enabled'
end

Given /^"([^\"]*)" feature is "enabled" with "([^\"]*)"$/ do |feature, options_str|
  @activation_commands ||= []

  options = eval("{#{options_str}}")

  @activation_commands << -> { activate(feature.to_sym, options) }
end

Given /^"([^\"]*)" is set to "([^\"]*)"$/ do |variable, value|
  @initialize_commands ||= []
  @initialize_commands << lambda {
    config[variable.to_sym] = value
  }
end

Given /^the Server is running$/ do
  root_dir = File.expand_path(expand_path('.'))

  ENV['MM_SOURCE'] = if File.exist?(File.join(root_dir, 'source'))
                       'source'
                     else
                       ''
                     end

  ENV['MM_ROOT'] = root_dir

  initialize_commands = @initialize_commands || []
  activation_commands = @activation_commands || []

  @server_inst = ::Middleman::Application.new do
    config[:watcher_disable] = true
    config[:show_exceptions] = false

    initialize_commands.each do |p|
      instance_exec(&p)
    end

    app.after_configuration_eval do
      activation_commands.each do |p|
        instance_exec(&p)
      end
    end
  end

  Capybara.app = ::Middleman::Rack.new(@server_inst).to_app
end

Given /^the Server is running at "([^\"]*)"$/ do |app_path|
  step %(a fixture app "#{app_path}")
  step %(the Server is running)
end

When /^the Server is reloaded$/ do
  step %(the Server is running)
end

Given /^a template named "([^\"]*)" with:$/ do |name, string|
  step %(a file named "source/#{name}" with:), string
end

When /^I go to "([^\"]*)"$/ do |url|
  visit(URI.encode(url).to_s)
end

Then /^going to "([^\"]*)" should not raise an exception$/ do |url|
  expect { visit(URI.encode(url).to_s) }.to_not raise_exception
end

Then /^the content type should be "([^\"]*)"$/ do |expected|
  expect(page.response_headers['Content-Type']).to start_with expected
end

Then /^the "([^\"]*)" header should contain "([^\"]*)"$/ do |header, expected|
  expect(page.response_headers[header]).to include expected
end

Then /^I should see "([^\"]*)"$/ do |expected|
  expect(page.body).to include expected
end

Then /^I should see '([^\']*)'$/ do |expected|
  expect(page.body).to include expected
end

Then /^I should see:$/ do |expected|
  expect(page.body).to include expected
end

Then /^I should not see "([^\"]*)"$/ do |expected|
  expect(page.body).not_to include expected
end

Then /^I should see content matching %r{(.*)}$/ do |expected|
  expect(page.body).to match(expected)
end

Then /^I should not see content matching %r{(.*)}$/ do |expected|
  expect(page.body).to_not match(expected)
end

Then /^I should not see:$/ do |expected|
  expect(page.body).not_to include expected
end

Then /^the status code should be "([^\"]*)"$/ do |expected|
  expect(page.status_code).to eq expected.to_i
end

Then /^I should see "([^\"]*)" lines$/ do |lines|
  expect(page.body.chomp.split($INPUT_RECORD_SEPARATOR).length).to eq lines.to_i
end
