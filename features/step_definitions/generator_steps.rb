require 'fileutils'

Given /^generated directory at "([^\"]*)"$/ do |dirname|
  target = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "fixtures", dirname)
  init_cmd = File.expand_path(File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "bin", "middleman init"))
  `cd #{File.dirname(target)} && #{init_cmd} #{File.basename(target)}`
end

Then /^template files should exist at "([^\"]*)"$/ do |dirname|
  target = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "fixtures", dirname)
  template_glob = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "lib", "middleman", "templates", "default", "*/**/*")
  
  Dir[template_glob].each do |f|
    next if File.directory?(f)
    File.exists?("#{target}/#{f.split('template/')[1]}").should be_true
  end
end

Then /^empty directories should exist at "([^\"]*)"$/ do |dirname|
  target = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "fixtures", dirname)
  
  %w(source/stylesheets source/javascripts source/images).each do |d|
    File.exists?("#{target}/#{d}").should be_true
  end
end

Then /^cleanup at "([^\"]*)"$/ do |dirname|
  target = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "fixtures", dirname)
  FileUtils.rm_rf(target)
end