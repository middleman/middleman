require 'bundler'
Bundler::GemHelper.install_tasks :name => ENV["NAME"] || "middleman"

require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:cucumber, 'Run features that should pass') do |t|
  t.cucumber_opts = "--color --tags ~@wip --strict --format #{ENV['CUCUMBER_FORMAT'] || 'pretty'}"
end

require 'rake/clean'

task :test => ["cucumber"]

desc "Build HTML documentation"
task :doc do
  sh 'bundle exec yard'
end
