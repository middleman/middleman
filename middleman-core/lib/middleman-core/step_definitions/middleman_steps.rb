require "fileutils"

Given /^a project at "([^\"]*)"$/ do |dirname|
  @target = File.join(PROJECT_ROOT_PATH, "fixtures", dirname)
end

Then /^the file "([^\"]*)" has the contents$/ do |path, contents|
  file_path = File.expand_path(path, @target)
  File.open(file_path, 'w') { |f| f.write(contents) }
  step %Q{the file "#{path}" did change}
end

Then /^the file "([^\"]*)" did change$/ do |path|
  @server_inst.file_did_change(path)
end