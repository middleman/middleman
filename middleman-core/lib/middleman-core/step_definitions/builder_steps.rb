require 'fileutils'

Before do
  @modification_times = Hash.new
end

Given /^app "([^\"]*)" is using config "([^\"]*)"$/ do |path, config_name|
  target = File.join(PROJECT_ROOT_PATH, 'fixtures', path)
  config_path = File.join(current_dir, "config-#{config_name}.rb")
  config_dest = File.join(current_dir, 'config.rb')
  FileUtils.cp(config_path, config_dest)
end

Given /^an empty app$/ do
  step %Q{a directory named "empty_app"}
  step %Q{I cd to "empty_app"}
  ENV['MM_ROOT'] = nil
end

Given /^a fixture app "([^\"]*)"$/ do |path|
  ENV['MM_ROOT'] = nil

  # This step can be reentered from several places but we don't want
  # to keep re-copying and re-cd-ing into ever-deeper directories
  next if File.basename(current_dir) == path

  step %Q{a directory named "#{path}"}

  target_path = File.join(PROJECT_ROOT_PATH, 'fixtures', path)
  FileUtils.cp_r(target_path, current_dir)

  step %Q{I cd to "#{path}"}
end

Given /^a built app at "([^\"]*)"$/ do |path|
  step %Q{a fixture app "#{path}"}
  step %Q{I run `middleman build`}
end

Given /^was successfully built$/ do
  step %Q{a directory named "build" should exist}
  step %Q{the exit status should be 0}
end

Given /^a successfully built app at "([^\"]*)"$/ do |path|
  step %Q{a built app at "#{path}"}
  step %Q{was successfully built}
end

Given /^a built app at "([^\"]*)" with flags "([^\"]*)"$/ do |path, flags|
  step %Q{a fixture app "#{path}"}
  step %Q{I run `middleman build #{flags}`}
end

Given /^a successfully built app at "([^\"]*)" with flags "([^\"]*)"$/ do |path, flags|
  step %Q{a built app at "#{path}" with flags "#{flags}"}
  step %Q{was successfully built}
end

Given /^a modification time for a file named "([^\"]*)"$/ do |file|
  target = File.join(current_dir, file)
  @modification_times[target] = File.mtime(target)
end

Then /^the file "([^\"]*)" should not have been updated$/ do |file|
  target = File.join(current_dir, file)
  File.mtime(target).should == @modification_times[target]
end

# Provide this Aruba overload in case we're matching something with quotes in it
Then /^the file "([^"]*)" should contain '([^']*)'$/ do |file, partial_content|
  check_file_content(file, Regexp.new(Regexp.escape(partial_content)), true)
end

And /the file "(.*)" should be gzipped/ do |file|
  expect(File.binread(File.join(current_dir, file), 2)).to eq(['1F8B'].pack('H*'))
end
