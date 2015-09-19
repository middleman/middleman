Then /^the file "([^\"]*)" has the contents$/ do |path, contents|
  File.write(File.expand_path(path), contents)

  @server_inst.files.find_new_files!
end

Then /^the file "([^\"]*)" is removed$/ do |path|
  File.delete(File.expand_path(path))

  @server_inst.files.find_new_files!
end
