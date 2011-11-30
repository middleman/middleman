require 'fileutils'

Given /^the project has been initialized$/ do
  step %Q{the project should be cleaned up}
  init_cmd = File.join(MIDDLEMAN_BIN_PATH, "middleman init")
  `cd #{File.dirname(@target)} && #{init_cmd} #{File.basename(@target)}`
end

Then /^template files should exist$/ do
  template_glob = File.join(MIDDLEMAN_ROOT_PATH, "lib", "middleman", "templates", "default", "*/**/*")
  
  Dir[template_glob].each do |f|
    next if File.directory?(f)
    File.exists?("#{@target}/#{f.split('template/')[1]}").should be_true
  end
end

Then /^empty directories should exist$/ do
  %w(source/stylesheets source/javascripts source/images).each do |d|
    File.exists?("#{@target}/#{d}").should be_true
  end
end

Then /^the project should be cleaned up$/ do
  FileUtils.rm_rf(@target)
end