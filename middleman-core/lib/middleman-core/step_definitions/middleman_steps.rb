Then /^the file "([^\"]*)" has the contents$/ do |path, contents|
  write_file(path, contents)
  @server_inst.files.find_new_files!
end

Then /^the file "([^\"]*)" is removed$/ do |path|
  step %Q{I remove the file "#{path}"}
  @server_inst.files.find_new_files!
end
