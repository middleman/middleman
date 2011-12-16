require 'fileutils'

Given /^app "([^\"]*)" is using config "([^\"]*)"$/ do |path, config_name|
  target = File.join(PROJECT_ROOT_PATH, "fixtures", path)
  config_path = File.join(target, "config-#{config_name}.rb")
  config_dest = File.join(target, "config.rb")
  FileUtils.cp(config_path, config_dest)
end

Given /^a fixture app "([^\"]*)"$/ do |path|
  step %Q{a directory named "#{path}"}

  target_path = File.join(PROJECT_ROOT_PATH, "fixtures", path)
  FileUtils.cp_r(target_path, current_dir)
  
  step %Q{I cd to "#{path}"}
end

Given /^a built app at "([^\"]*)"$/ do |path|
  step %Q{a fixture app "#{path}"}
  step %Q{I run `middleman build`}
end

Given /^a built app at "([^\"]*)" with flags "([^\"]*)"$/ do |path, flags|
  step %Q{a fixture app "#{path}"}
  step %Q{I run `middleman build #{flags}`}
end

Then /^"([^\"]*)" should exist at "([^\"]*)"$/ do |target_file, path|
  target = File.join(PROJECT_ROOT_PATH, "fixtures", path, "build", target_file)
  File.exists?(target).should be_true
end

Then /^"([^\"]*)" should exist at "([^\"]*)" and include "([^\"]*)"$/ do |target_file, path, expected|
  target = File.join(PROJECT_ROOT_PATH, "fixtures", path, "build", target_file)
  File.exists?(target).should be_true
  File.read(target).should include(expected)
end

Then /^"([^\"]*)" should not exist at "([^\"]*)"$/ do |target_file, path|
  target = File.join(PROJECT_ROOT_PATH, "fixtures", path, "build", target_file)
  File.exists?(target).should be_false
end

Then /^the last exit code should be "([^\"]*)"$/ do |exit_code|
  exit_code = exit_code.to_i
  $?.exitstatus.should == exit_code
end
