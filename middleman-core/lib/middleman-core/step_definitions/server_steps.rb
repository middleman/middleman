require 'rspec/expectations'
require 'capybara/cucumber'

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
  if exist? 'source'
    set_environment_variable 'MM_SOURCE', 'source'
  else
    set_environment_variable 'MM_SOURCE', ''
  end

  set_environment_variable 'MM_ROOT', expand_path('.')

  initialize_commands = @initialize_commands || []
  initialize_commands.unshift lambda {
    set :environment, @current_env || :development
    set :show_exceptions, false
  }

  cd '.' do
    with_environment do
      @server_inst = Middleman::Application.server.inst do
        initialize_commands.each do |p|
          instance_exec(&p)
        end
      end
    end
  end

  Capybara.app =  @server_inst.class.to_rack_app
end

Given /^the Server is running at "([^\"]*)"$/ do |app_path|
  step %Q{a fixture app "#{app_path}"}
  step %Q{the Server is running}
end

Given /^a template named "([^\"]*)" with:$/ do |name, string|
  step %Q{a file named "source/#{name}" with:}, string
end

When /^I go to "([^\"]*)"$/ do |url|
  cd '.' do
    with_environment do
      visit(URI.encode(url).to_s)
    end
  end
end

Then /^going to "([^\"]*)" should not raise an exception$/ do |url|
  cd '.' do
    with_environment do
      expect{ visit(URI.encode(url).to_s) }.to_not raise_exception
    end
  end
end

Then /^the content type should be "([^\"]*)"$/ do |expected|
  cd '.' do
    with_environment do
      expect(page.response_headers['Content-Type']).to start_with expected
    end
  end
end

Then /^I should see "([^\"]*)"$/ do |expected|
  cd '.' do
    with_environment do
      expect(page.body).to include expected
    end
  end
end

Then /^I should see '([^\']*)'$/ do |expected|
  cd '.' do
    with_environment do
      expect(page.body).to include expected
    end
  end
end

Then /^I should see:$/ do |expected|
  cd '.' do
    with_environment do
      expect(page.body).to include expected
    end
  end
end

Then /^I should not see "([^\"]*)"$/ do |expected|
  cd '.' do
    with_environment do
      expect(page.body).not_to include expected
    end
  end
end

Then /^I should not see:$/ do |expected|
  cd '.' do
    with_environment do
      expect(page.body).not_to include expected
    end
  end
end

Then /^the status code should be "([^\"]*)"$/ do |expected|
  cd '.' do
    with_environment do
      expect(page.status_code).to eq expected.to_i
    end
  end
end

Then /^I should see "([^\"]*)" lines$/ do |lines|
  cd '.' do
    with_environment do
      expect(page.body.chomp.split($/).length).to eq lines.to_i
    end
  end
end
