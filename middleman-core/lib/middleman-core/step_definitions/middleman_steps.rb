# frozen_string_literal: true

require 'fileutils'

Given /^app "([^\"]*)" is using config "([^\"]*)"$/ do |_path, config_name|
  config_path = File.join(expand_path('.'), "config-#{config_name}.rb")
  config_dest = File.join(expand_path('.'), 'config.rb')
  FileUtils.cp(config_path, config_dest)
end

Given /^an empty app$/ do
  ENV['MM_ROOT'] = nil

  # This step can be reentered from several places but we don't want
  # to keep re-copying and re-cd-ing into ever-deeper directories
  next if File.basename(expand_path('.')) == 'empty_app'

  step %(a directory named "empty_app")
  step %(I cd to "empty_app")

  cwd = File.expand_path(aruba.current_directory)
  step %(I set the environment variable "MM_ROOT" to "#{cwd}")
end

Given /^a fixture app "([^\"]*)"$/ do |path|
  ENV['MM_ROOT'] = nil

  # This step can be reentered from several places but we don't want
  # to keep re-copying and re-cd-ing into ever-deeper directories
  next if File.basename(expand_path('.')) == path

  step %(a directory named "#{path}")

  target_path = File.join(PROJECT_ROOT_PATH, 'fixtures', path)
  FileUtils.cp_r(target_path, expand_path('.'))

  step %(I cd to "#{path}")

  cwd = File.expand_path(aruba.current_directory)
  step %(I set the environment variable "MM_ROOT" to "#{cwd}")
end

Then /^the file "([^\"]*)" has the contents$/ do |path, contents|
  write_file(path, contents)

  @server_inst.files.poll_once!
end

Then /^the file "([^\"]*)" is removed$/ do |path|
  step %(I remove the file "#{path}")

  @server_inst.files.poll_once!
end

Given /^a modification time for a file named "([^\"]*)"$/ do |file|
  target = File.join(expand_path('.'), file)
  @modification_times[target] = File.mtime(target)
end

Then /^the file "([^\"]*)" should not have been updated$/ do |file|
  target = File.join(expand_path('.'), file)
  expect(File.mtime(target)).to eq(@modification_times[target])
end

# Provide this Aruba overload in case we're matching something with quotes in it
Then /^the file "([^"]*)" should contain '([^']*)'$/ do |file, partial_content|
  expect(file).to have_file_content(Regexp.new(Regexp.escape(partial_content)), true)
end

And /the file "(.*)" should be gzipped/ do |file|
  expect(File.binread(File.join(expand_path('.'), file), 2)).to eq(['1F8B'].pack('H*'))
end
