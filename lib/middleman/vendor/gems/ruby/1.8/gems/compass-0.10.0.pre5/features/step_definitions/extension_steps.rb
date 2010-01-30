Given /^the "([^\"]*)" directory exists$/ do |directory|
  FileUtils.mkdir_p directory
end

Given /^and I have a fake extension at (.*)$/ do |directory|
  FileUtils.mkdir_p File.join(directory, 'stylesheets')
  FileUtils.mkdir_p File.join(directory, 'templates/project')
end

Then /^the list of frameworks includes "([^\"]*)"$/ do |framework|
  @last_result.split("\n").map{|f| f.strip}.should include(framework)
end

