require 'fileutils'

Before do
  @modification_times = {}
end

Given /^a built app at "([^\"]*)"$/ do |path|
  step %(a fixture app "#{path}")
  step %(I run `middleman build --verbose --no-parallel`)
end

Then /^build the app tracking dependencies$/ do
  step %(I run `middleman build --track-dependencies --verbose`)
  step %(was successfully built)
end

Then('build the app tracking dependencies with depth {string}') do |depth|
  step %(I run `middleman build --track-dependencies --verbose --data-collection-depth=#{depth}`)
  step %(was successfully built)
end

Then /^build app with only changed$/ do
  step %(I run `middleman build --track-dependencies --only-changed --verbose`)
  step %(was successfully built)
end

Given /^was successfully built$/ do
  step %(the output should contain "Project built successfully.")
  step %(the exit status should be 0)
  step %(a directory named "build" should exist)
end

Given /^was not successfully built$/ do
  step %(the output should not contain "Project built successfully.")
  step %(the exit status should not be 0)
  step %(a directory named "build" should not exist)
end

Given /^a successfully built app at "([^\"]*)"$/ do |path|
  step %(a built app at "#{path}")
  step %(was successfully built)
end

Given /^a built app at "([^\"]*)" with flags "([^\"]*)"$/ do |path, flags|
  step %(a fixture app "#{path}")

  cwd = File.expand_path(aruba.current_directory)
  step %(I set the environment variable "MM_ROOT" to "#{cwd}")

  step %(I run `middleman build --no-parallel #{flags}`)
end

Given /^a successfully built app at "([^\"]*)" with flags "([^\"]*)"$/ do |path, flags|
  step %(a built app at "#{path}" with flags "#{flags}")
  step %(was successfully built)
end

Given /^I run the interactive middleman console$/ do
  cwd = File.expand_path(aruba.current_directory)
  step %(I set the environment variable "MM_ROOT" to "#{cwd}")
  step %(I run `middleman console` interactively)
end

Given /^I run the interactive middleman server$/ do
  cwd = File.expand_path(aruba.current_directory)
  step %(I set the environment variable "MM_ROOT" to "#{cwd}")
  step %(I run `middleman server` interactively)
end

Then('there are {string} files which are {string}') do |num, str|
  expect(last_command_started.output.scan(str).length).to be num.to_i
end

Then('there are {string} files which are created') do |num|
  step %(there are "#{num}" files which are "      create  ")
end

Then('there are {string} files which are removed') do |num|
  step %(there are "#{num}" files which are "      remove  ")
end

Then('there are {string} files which are updated') do |num|
  step %(there are "#{num}" files which are "     updated  ")
end

Then('there are {string} files which are identical') do |num|
  step %(there are "#{num}" files which are "   identical  ")
end

Then('there are {string} files which are skipped') do |num|
  step %(there are "#{num}" files which are "     skipped  ")
end
