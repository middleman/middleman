require 'fileutils'

Given /^app "([^"]*)" is using config "([^"]*)"$/ do |path, config_name|
  root = File.dirname(File.dirname(File.dirname(__FILE__)))
  target = File.join(root, "fixtures", path)
  config_path = File.join(target, "config-#{config_name}.rb")
  config_dest = File.join(target, "config.rb")
  FileUtils.cp(config_path, config_dest)
end

Given /^a built app at "([^"]*)"$/ do |path|
  root = File.dirname(File.dirname(File.dirname(__FILE__)))
  target = File.join(root, "fixtures", path)
  build_cmd = File.expand_path(File.join(root, "bin", "middleman build"))
  `cd #{target} && #{build_cmd}`
end

Then /^cleanup built app at "([^"]*)"$/ do |path|
  root = File.dirname(File.dirname(File.dirname(__FILE__)))
  target = File.join(root, "fixtures", path, "build")
  FileUtils.rm_rf(target)
end

Given /^a built app at "([^"]*)" with flags "([^"]*)"$/ do |path, flags|
  root = File.dirname(File.dirname(File.dirname(__FILE__)))
  target = File.join(root, "fixtures", path)
  build_cmd = File.expand_path(File.join(root, "bin", "middleman build"))
  `cd #{target} && #{build_cmd} #{flags}`
end

Then /^"([^"]*)" should exist at "([^"]*)"$/ do |target_file, path|
  root = File.dirname(File.dirname(File.dirname(__FILE__)))
  target = File.join(root, "fixtures", path, "build", target_file)
  File.exists?(target).should be_true
end

Then /^"([^"]*)" should exist at "([^"]*)" and include "([^"]*)"$/ do |target_file, path, expected|
  root = File.dirname(File.dirname(File.dirname(__FILE__)))
  target = File.join(root, "fixtures", path, "build", target_file)
  File.exists?(target).should be_true
  File.read(target).should include(expected)
end

Then /^"([^"]*)" should not exist at "([^"]*)"$/ do |target_file, path|
  root = File.dirname(File.dirname(File.dirname(__FILE__)))
  target = File.join(root, "fixtures", path, "build", target_file)
  File.exists?(target).should be_false
end