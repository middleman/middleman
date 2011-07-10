require 'fileutils'

Given /^a built test app$/ do
  target = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "fixtures", "test-app")
  build_cmd = File.expand_path(File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "bin", "mm-build"))
  `cd #{target} && MM_DIR="#{target}" #{build_cmd}`
end

Given /^a built test app with flags "([^"]*)"$/ do |flags|
  target = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "fixtures", "test-app")
  build_cmd = File.expand_path(File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "bin", "mm-build"))
  `cd #{target} && MM_DIR="#{target}" #{build_cmd} #{flags}`
end

Given /^cleanup built test app$/ do
  target = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "fixtures", "test-app", "build")
  FileUtils.rm_rf(target)
end

Then /^"([^"]*)" should exist and include "([^"]*)"$/ do |target_file, expected|
  target = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "fixtures", "test-app", "build", target_file)
  File.exists?(target).should be_true
  File.read(target).should include(expected)
end

Then /^"([^"]*)" should not exist$/ do |target_file|
  target = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "fixtures", "test-app", "build", target_file)
  File.exists?(target).should be_false
end