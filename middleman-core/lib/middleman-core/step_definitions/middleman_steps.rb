require 'fileutils'

Given /^app "([^\"]*)" is using config "([^\"]*)"$/ do |path, config_name|
  copy "config-#{config_name}.rb", 'config.rb'
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
  next if File.basename(expand_path(".")) == path

  step %Q{a directory named "#{path}"}

  copy "%/#{path}", '.'

  step %Q{I cd to "#{path}"}
end

Then /^the file "([^\"]*)" has the contents$/ do |path, contents|
  write_file(path, contents)

  with_environment do
    @server_inst.files.find_new_files!
  end
end

Then /^the file "([^\"]*)" is removed$/ do |path|
  step %Q{I remove the file "#{path}"}

  with_environment do
    @server_inst.files.find_new_files!
  end
end

Given /^a modification time for a file named "([^\"]*)"$/ do |file|
  target = expand_path(file)
  @modification_times[target] = File.mtime(target)
end

Then /^the file "([^\"]*)" should not have been updated$/ do |file|
  target = expand_path(file)
  expect(File.mtime(target)).to eq(@modification_times[target])
end

# Provide this Aruba overload in case we're matching something with quotes in it
Then /^the file "([^"]*)" should contain '([^']*)'$/ do |file, partial_content|
  expect(file).to have_file_content(Regexp.new(Regexp.escape(partial_content)), true)
end

And /the file "(.*)" should be gzipped/ do |file|
  expect(File.binread(expand_path(file), 2)).to eq(['1F8B'].pack('H*'))
end
