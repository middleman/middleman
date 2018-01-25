require 'fileutils'

Before do
  @modification_times = Hash.new
end

Given /^a built app at "([^\"]*)"$/ do |path|
  step %Q{a fixture app "#{path}"}

  cwd = File.expand_path(aruba.current_directory)
  step %Q{I set the environment variable "MM_ROOT" to "#{cwd}"}

  step %Q{I run `middleman build --verbose`}
end

Given /^was successfully built$/ do
  step %Q{the output should contain "Project built successfully."}
  step %Q{the exit status should be 0}
  step %Q{a directory named "build" should exist}
end

Given /^a successfully built app at "([^\"]*)"$/ do |path|
  step %Q{a built app at "#{path}"}
  step %Q{was successfully built}
end

Given /^a built app at "([^\"]*)" with flags "([^\"]*)"$/ do |path, flags|
  step %Q{a fixture app "#{path}"}
  
  cwd = File.expand_path(aruba.current_directory)
  step %Q{I set the environment variable "MM_ROOT" to "#{cwd}"}

  step %Q{I run `middleman build #{flags}`}
end

Given /^a successfully built app at "([^\"]*)" with flags "([^\"]*)"$/ do |path, flags|
  step %Q{a built app at "#{path}" with flags "#{flags}"}
  step %Q{was successfully built}
end
