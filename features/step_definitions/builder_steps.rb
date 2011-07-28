require 'fileutils'

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

Given /^a built test app with flags "([^"]*)"$/ do |flags|
  target = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "fixtures", "test-app")
  build_cmd = File.expand_path(File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "bin", "middleman build"))
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