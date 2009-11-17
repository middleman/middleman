Given /^I do not want cucumber stories$/ do
  @use_cucumber = false
end

Given /^I want cucumber stories$/ do
  @use_cucumber = true
end

Given /^I do not want reek$/ do
  @use_reek = false
end

Given /^I want reek$/ do
  @use_reek = true
end

Given /^I do not want roodi$/ do
  @use_roodi = false
end

Given /^I want roodi$/ do
  @use_roodi = true
end

And /^I do not want rubyforge setup$/ do
  @use_rubyforge = false
end

And /^I want rubyforge setup$/ do
  @use_rubyforge = true
end

Given /^I want to use yard instead of rdoc$/ do
  @documentation_framework = "yard"
end

Given /^I want to use rdoc instead of yard$/ do
  @documentation_framework = "rdoc"
end


Given /^I intend to test with (\w+)$/ do |testing_framework|
  @testing_framework = testing_framework.to_sym
end

Given /^I have configured git sanely$/ do
  @user_email = 'bar@example.com'
  @user_name = 'foo'
  @github_user = 'technicalpickles'
  @github_token = 'zomgtoken'

  require 'git'
  Git.stubs(:global_config).
        returns({
          'user.name' => @user_name,
          'user.email' => @user_email,
          'github.user' => @github_user,
          'github.token' => @github_token})
end

Given /^I set JEWELER_OPTS env variable to "(.*)"$/ do |val|
  ENV['JEWELER_OPTS'] = val
end

When /^I generate a (.*)project named '((?:\w|-|_)+)' that is '([^']*)'$/ do |testing_framework, name, summary|
  When "I generate a #{testing_framework}project named '#{name}' that is '#{summary}' and described as ''"
end

When /^I generate a (.*)project named '((?:\w|-|_)+)' that is '([^']*)' and described as '([^']*)'$/ do |testing_framework, name, summary, description|
  @name = name
  @summary = summary
  @description = description

  testing_framework = testing_framework.squeeze.strip
  unless testing_framework.blank?
    @testing_framework = testing_framework.to_sym
  end


  arguments = ['--directory',
               "#{@working_dir}/#{@name}",
               '--summary', @summary,
               '--description', @description,
                @use_cucumber ? '--cucumber' : nil,
                @testing_framework ? "--#{@testing_framework}" : nil,
                @use_rubyforge ? '--rubyforge' : nil,
                @use_roodi ? '--roodi' : nil,
                @use_reek ? '--reek' : nil,
                @documentation_framework ? "--#{@documentation_framework}" : nil,
                @name].compact

  @stdout = OutputCatcher.catch_out do
    Jeweler::Generator::Application.run! *arguments
  end

  @repo = Git.open(File.join(@working_dir, @name))
end

Then /^a directory named '(.*)' is created$/ do |directory|
  directory = File.join(@working_dir, directory)

  assert File.exists?(directory), "#{directory} did not exist"
  assert File.directory?(directory), "#{directory} is not a directory"
end

Then "cucumber directories are created" do
  Then "a directory named 'the-perfect-gem/features' is created"
  Then "a directory named 'the-perfect-gem/features/support' is created"
  Then "a directory named 'the-perfect-gem/features/step_definitions' is created"
end


Then /^a file named '(.*)' is created$/ do |file|
  file = File.join(@working_dir, file)

  assert File.exists?(file), "#{file} expected to exist, but did not"
  assert File.file?(file), "#{file} expected to be a file, but is not"
end

Then /^a file named '(.*)' is not created$/ do |file|
  file = File.join(@working_dir, file)

  assert ! File.exists?(file), "#{file} expected to not exist, but did"
end

Then /^a sane '.gitignore' is created$/ do
  Then "a file named 'the-perfect-gem/.gitignore' is created"
  Then "'coverage' is ignored by git"
  Then "'*.sw?' is ignored by git"
  Then "'.DS_Store' is ignored by git"
  Then "'rdoc' is ignored by git"
  Then "'pkg' is ignored by git"
end

Then /^'(.*)' is ignored by git$/ do |git_ignore|
  @gitignore_content ||= File.read(File.join(@working_dir, @name, '.gitignore'))

  assert_match git_ignore, @gitignore_content
end

Then /^Rakefile has '(.*)' for the (.*) (.*)$/ do |value, task_class, field|
  @rakefile_content ||= File.read(File.join(@working_dir, @name, 'Rakefile'))
  block_variable, task_block = yank_task_info(@rakefile_content, task_class)
  #raise "Found in #{task_class}: #{block_variable.inspect}: #{task_block.inspect}"

  assert_match /#{block_variable}\.#{field} = (%Q\{|"|')#{Regexp.escape(value)}(\}|"|')/, task_block
end

Then /^Rakefile has '(.*)' in the Rcov::RcovTask libs$/ do |libs|
  @rakefile_content ||= File.read(File.join(@working_dir, @name, 'Rakefile'))
  block_variable, task_block = yank_task_info(@rakefile_content, 'Rcov::RcovTask')

  assert_match "#{block_variable}.libs << '#{libs}'", @rakefile_content
end


Then /^'(.*)' contains '(.*)'$/ do |file, expected_string|
  contents = File.read(File.join(@working_dir, @name, file))
  assert_match expected_string, contents
end

Then /^'(.*)' mentions copyright belonging to me in (\d{4})$/ do |file, year|
  contents = File.read(File.join(@working_dir, @name, file))
  assert_match "Copyright (c) #{year} #{@user_name}", contents
end

Then /^'(.*)' mentions copyright belonging to me in the current year$/ do |file|
  current_year = Time.now.year
  Then "'#{file}' mentions copyright belonging to me in #{current_year}"
end


Then /^LICENSE has the copyright as belonging to '(.*)' in '(\d{4})'$/ do |copyright_holder, year|
  Then "a file named 'the-perfect-gem/LICENSE' is created"

  @license_content ||= File.read(File.join(@working_dir, @name, 'LICENSE'))

  assert_match copyright_holder, @license_content

  assert_match year, @license_content
end

Then /^'(.*)' should define '(.*)' as a subclass of '(.*)'$/ do |file, class_name, superclass_name|
  @test_content = File.read((File.join(@working_dir, @name, file)))

  assert_match "class #{class_name} < #{superclass_name}", @test_content
end

Then /^'(.*)' should describe '(.*)'$/ do |file, describe_name|
  @spec_content ||= File.read((File.join(@working_dir, @name, file)))

  assert_match %Q{describe "#{describe_name}" do}, @spec_content
end

Then /^'(.*)' should contextualize '(.*)'$/ do |file, describe_name|
  @spec_content ||= File.read((File.join(@working_dir, @name, file)))

  assert_match %Q{context "#{describe_name}" do}, @spec_content
end

Then /^'(.*)' requires '(.*)'$/ do |file, lib|
  content = File.read(File.join(@working_dir, @name, file))

  assert_match /require ['"]#{Regexp.escape(lib)}['"]/, content
end

Then /^'(.*)' does not require '(.*)'$/ do |file, lib|
  content = File.read(File.join(@working_dir, @name, file))

  assert_no_match /require ['"]#{Regexp.escape(lib)}['"]/, content
end

Then /^Rakefile does not require '(.*)'$/ do |file|
  Then "'Rakefile' does not require '#{file}'"
end

Then /^Rakefile requires '(.*)'$/ do |file|
  Then "'Rakefile' requires '#{file}'"
end

Then /^Rakefile does not instantiate a (.*)$/ do |task_name|
  content = File.read(File.join(@working_dir, @name, 'Rakefile'))
  assert_no_match /#{task_name}/, content
end

Then /^Rakefile instantiates a (.*)$/ do |task_name|
  content = File.read(File.join(@working_dir, @name, 'Rakefile'))
  assert_match /#{task_name}/, content
end


Then /^'(.+?)' should autorun tests$/ do |test_helper|
  content = File.read(File.join(@working_dir, @name, test_helper))

  assert_match "MiniTest::Unit.autorun", content
end

Then /^cucumber world extends "(.*)"$/ do |module_to_extend|
  content = File.read(File.join(@working_dir, @name, 'features', 'support', 'env.rb'))
  assert_match "World(#{module_to_extend})", content
end


Then /^'features\/support\/env\.rb' sets up features to use test\/unit assertions$/ do

end

Then /^'features\/support\/env\.rb' sets up features to use minitest assertions$/ do
  content = File.read(File.join(@working_dir, @name, 'features', 'support', 'env.rb'))

  assert_match "world.extend(Mini::Test::Assertions)", content
end

Then /^git repository has '(.*)' remote$/ do |remote|
  remote = @repo.remotes.first

  assert_equal 'origin', remote.name
end

Then /^git repository '(.*)' remote should be '(.*)'/ do |remote, remote_url|
  remote = @repo.remotes.first

  assert_equal 'git@github.com:technicalpickles/the-perfect-gem.git', remote.url
end

Then /^a commit with the message '(.*)' is made$/ do |message|
  assert_match message, @repo.log.first.message
end

Then /^'(.*)' was checked in$/ do |file|
  status = @repo.status[file]

  assert_not_nil status, "wasn't able to get status for #{file}"
  assert ! status.untracked, "#{file} was untracked"
  assert_nil status.type, "#{file} had a type. it should have been nil"
end

Then /^no files are (\w+)$/ do |type|
  assert_equal 0, @repo.status.send(type).size
end

Then /^Rakefile has "(.*)" as the default task$/ do |task|
  @rakefile_content ||= File.read(File.join(@working_dir, @name, 'Rakefile'))
  assert_match "task :default => :#{task}", @rakefile_content
end


After do
  ENV['JEWELER_OPTS'] = nil
  FileUtils.rm_rf @working_dir if @working_dir
end
