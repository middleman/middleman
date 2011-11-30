Given /^a project at "([^\"]*)"$/ do |dirname|
  @target = File.join(PROJECT_ROOT_PATH, "fixtures", dirname)
end