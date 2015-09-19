Then /^the file "([^\"]*)" has the contents$/ do |path, contents|
  write_file(path, contents)

  # cd(".") do
    @server_inst.files.find_new_files!
  # end
end

Then /^the file "([^\"]*)" is removed$/ do |path|
  step %Q{I remove the file "#{path}"}

  # cd(".") do
    @server_inst.files.find_new_files!
  # end
end
