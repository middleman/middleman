Then /^the file "([^\"]*)" has the contents$/ do |path, contents|
  write_file(path, contents)

  in_current_dir do
    @server_inst.files.find_new_files!
  end
end

Then /^the file "([^\"]*)" is removed$/ do |path|
  step %Q{I remove the file "#{path}"}

  in_current_dir do
    @server_inst.files.find_new_files!
  end
end
