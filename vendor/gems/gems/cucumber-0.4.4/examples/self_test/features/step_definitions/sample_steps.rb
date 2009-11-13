def flunker
  raise "FAIL"
end

Given /^passing$/ do |table|
end

Given /^failing$/ do |string|
  flunker
end

Given /^passing without a table$/ do
end

Given /^failing without a table$/ do
  flunker
end

Given /^a step definition that calls an undefined step$/ do
  Given 'this does not exist'
end

Given /^call step "(.*)"$/ do |step|
  Given step
end

Given /^'(.+)' cukes$/ do |cukes|
  raise "We already have #{@cukes} cukes!" if @cukes
  @cukes = cukes
end
Then /^I should have '(.+)' cukes$/ do |cukes|
  @cukes.should == cukes
end

Given /^'(.+)' global cukes$/ do |cukes|
  $scenario_runs ||= 0
  flunker if $scenario_runs >= 1
  $cukes = cukes
  $scenario_runs += 1
end

Then /^I should have '(.+)' global cukes$/ do |cukes|
  $cukes.should == cukes
end

Given /^table$/ do |table|
  @table = table
end

Given /^multiline string$/ do |string|
  @multiline = string
end

Then /^the table should be$/ do |table|
  @table.raw.should == table.raw
end

Then /^the multiline string should be$/ do |string|
  @multiline.should == string
end

Given /^failing expectation$/ do
  'this'.should == 'that'
end

Given /^unused$/ do
end

Given /^another unused$/ do
end

after_file = File.expand_path(File.dirname(__FILE__) + '/../../tmp/after.txt')

Before do
  FileUtils.rm(after_file) if File.exist?(after_file)
end

After('@after_file') do
  FileUtils.mkdir_p(File.dirname(after_file))
  FileUtils.touch(after_file)
end
