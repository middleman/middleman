require 'fileutils'

Given /^app "([^\"]*)" is using config "([^\"]*)"$/ do |path, config_name|
  target = File.join(PROJECT_ROOT_PATH, "fixtures", path)
  config_path = File.join(target, "config-#{config_name}.rb")
  config_dest = File.join(target, "config.rb")
  FileUtils.cp(config_path, config_dest)
end

Given /^a built app at "([^\"]*)"$/ do |path|
  target = File.join(PROJECT_ROOT_PATH, "fixtures", path)
  
  build_target = File.join(target, "build")
  FileUtils.rm_rf(build_target)
  
  build_cmd = File.join(MIDDLEMAN_BIN_PATH, "middleman build")
  `cd #{target} && #{build_cmd}`
end

Then /^cleanup built app at "([^\"]*)"$/ do |path|
  target = File.join(PROJECT_ROOT_PATH, "fixtures", path, "build")
  FileUtils.rm_rf(target)
end

Given /^a built app at "([^\"]*)" with flags "([^\"]*)"$/ do |path, flags|
  target = File.join(PROJECT_ROOT_PATH, "fixtures", path)
  build_cmd = File.join(MIDDLEMAN_BIN_PATH, "middleman build")
  `cd #{target} && #{build_cmd} #{flags}`
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
