require 'rubygems' unless defined?(Gem)
require 'rake'
require 'cucumber/rake/task'
require 'bundler/gem_tasks'
require 'yard'

# Skip the releasing tag
class Bundler::GemHelper
  def release_gem
    guard_clean
    guard_already_tagged
    built_gem_path = build_gem
    rubygem_push(built_gem_path)
  end
end

Cucumber::Rake::Task.new(:test, 'Run features that should pass') do |t|
  t.cucumber_opts = "--color --tags ~@wip --strict --format #{ENV['CUCUMBER_FORMAT'] || 'pretty'}"
end

task :default => :test