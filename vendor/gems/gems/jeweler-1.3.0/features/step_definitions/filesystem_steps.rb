Given 'a working directory' do
  @working_dir = File.expand_path File.join(File.dirname(__FILE__), '..', '..', 'tmp')
  FileUtils.rm_rf @working_dir
  FileUtils.mkdir_p @working_dir
end

Given /^I use the jeweler command to generate the "([^"]+)" project in the working directory$/ do |name|
  @name = name

  return_to = Dir.pwd
  path_to_jeweler = File.expand_path File.join(File.dirname(__FILE__), '..', '..', 'bin', 'jeweler')

  begin
    FileUtils.cd @working_dir
    @stdout = `#{path_to_jeweler} #{@name}`
  ensure
    FileUtils.cd return_to
  end
end

Given /^"([^"]+)" does not exist$/ do |file|
  assert ! File.exists?(File.join(@working_dir, file))
end

When /^I run "([^"]+)" in "([^"]+)"$/ do |command, directory|
  full_path = File.join(@working_dir, directory)

  lib_path = File.expand_path 'lib'
  command.gsub!(/^rake /, "rake --trace -I#{lib_path} ")

  assert File.directory?(full_path), "#{full_path} is not a directory"

  @stdout = `cd #{full_path} && #{command}`
  @exited_cleanly = $?.exited?
end

Then /^the updated version, (.*), is displayed$/ do |version|
  assert_match "Updated version: #{version}", @stdout
end

Then /^the current version, (\d+\.\d+\.\d+), is displayed$/ do |version|
  assert_match "Current version: #{version}", @stdout
end

Then /^the process should exit cleanly$/ do
  assert @exited_cleanly, "Process did not exit cleanly: #{@stdout}"
end

Then /^the process should not exit cleanly$/ do
  assert !@exited_cleanly, "Process did exit cleanly: #{@stdout}"
end

Given /^I use the existing project "([^"]+)" as a template$/ do |fixture_project|
  @name = fixture_project
  FileUtils.cp_r File.join(fixture_dir, fixture_project), @working_dir
end

Given /^"VERSION\.yml" contains hash "([^"]+)"$/ do |ruby_string|
  version_hash = YAML.load(File.read(File.join(@working_dir, @name, 'VERSION.yml')))
  evaled_hash = eval(ruby_string)
  assert_equal evaled_hash, version_hash
end

Given /^"VERSION" contains "([^\"]*)"$/ do |expected|
  version = File.read(File.join(@working_dir, @name, 'VERSION')).chomp
  assert_equal expected, version
end

