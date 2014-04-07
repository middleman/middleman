require 'bundler'
Bundler::GemHelper.install_tasks

require 'cucumber/rake/task'

require 'middleman-core/version'

Cucumber::Rake::Task.new(:cucumber, 'Run features that should pass') do |t|
  exempt_tags = ["--tags ~@wip"]
  t.cucumber_opts = "--color #{exempt_tags.join(" ")} --strict --format #{ENV['CUCUMBER_FORMAT'] || 'Fivemat'}"
end

require 'rake/clean'

task :test => [:cucumber]

desc "Build HTML documentation"
task :doc do
  sh 'bundle exec yard'
end
