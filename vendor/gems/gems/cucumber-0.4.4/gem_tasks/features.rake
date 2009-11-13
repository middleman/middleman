$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'cucumber/rake/task'
require 'cucumber/platform'

Cucumber::Rake::Task.new do |t|
  if(Cucumber::JRUBY)
    t.profile = 'jruby'
  elsif(Cucumber::WINDOWS_MRI)
    t.profile = 'windows_mri'
  end
  t.rcov = ENV['RCOV']
end

Cucumber::Rake::Task.new('pretty') do |t|
  t.cucumber_opts = %w{--format pretty}
end