Then /^the file "([^\"]*)" has the contents$/ do |path, contents|
  write_file(path, contents)
  step %Q{the file "#{path}" did change}
end

Then /^the file "([^\"]*)" is removed$/ do |path|
  step %Q{I remove the file "#{path}"}
  step %Q{the file "#{path}" did delete}
end

Then /^the file "([^\"]*)" did change$/ do |path|
  @server_inst.files.did_change(path)
end

Then /^the file "([^\"]*)" did delete$/ do |path|
  @server_inst.files.did_delete(path)
end
