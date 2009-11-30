require 'fileutils'

Then /^template files should exist at "([^\"]*)"$/ do |dirname|
  target = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "spec", "fixtures", dirname)
  template_glob = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "lib", "middleman", "template", "*/**/*")
  
  Dir[template_glob].each do |f|
    next if File.directory?(f)
    File.exists?("#{target}/#{f.split('template/')[1]}").should be_true
  end
end

Then /^empty directories should exist at "([^\"]*)"$/ do |dirname|
  target = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "spec", "fixtures", dirname)
  
  %w(views/stylesheets public/stylesheets public/javascripts public/images).each do |d|
    File.exists?("#{target}/#{d}").should be_true
  end
end

Then /^cleanup at "([^\"]*)"$/ do |dirname|
  target = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "spec", "fixtures", dirname)
  FileUtils.rm_rf(target)
end