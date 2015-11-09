require 'fileutils'

Before do
  @modification_times = Hash.new
end

Given /^app "([^\"]*)" is using config "([^\"]*)"$/ do |path, config_name|
  copy("config-#{config_name}.rb", 'config.rb')
end

Given /^an empty app$/ do
  step %Q{a directory named "empty_app"}
  step %Q{I cd to "empty_app"}

  delete_environment_variable 'MM_ROOT'
end

Given /^a fixture app "([^\"]*)"$/ do |path|
  delete_environment_variable 'MM_ROOT'

  # This step can be reentered from several places but we don't want
  # to keep re-copying and re-cd-ing into ever-deeper directories
  next if File.basename(expand_path('.')) == path

  step %Q{a directory named "#{path}"}

  target_path = File.join(PROJECT_ROOT_PATH, 'fixtures', path)
  FileUtils.cp_r(target_path, expand_path('.'))

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
  target = expand_path(file)
  @modification_times[target] = File.mtime(target)
end

Then /^the file "([^\"]*)" should not have been updated$/ do |file|
  target = expand_path(file)
  File.mtime(target).should == @modification_times[target]
end

# Provide this Aruba overload in case we're matching something with quotes in it
Then /^the file "([^"]*)" should contain '([^']*)'$/ do |file, partial_content|
  expect(file).to have_file_content Regexp.new(Regexp.escape(partial_content))
end

And /the file "(.*)" should be gzipped/ do |file|
  expect(File.binread(expand_path(file), 2)).to eq(['1F8B'].pack('H*'))
end
