require 'bundler'
Bundler::GemHelper.install_tasks

require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:cucumber, 'Run features that should pass') do |t|
  t.cucumber_opts = "--color --tags ~@wip --strict --format #{ENV['CUCUMBER_FORMAT'] || 'pretty'}"
end

#$LOAD_PATH.unshift 'lib'

require 'rake/testtask'
require 'rake/clean'

task :test => ["cucumber"]