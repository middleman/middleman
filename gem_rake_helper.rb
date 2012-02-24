require 'rubygems' unless defined?(Gem)
require 'rake'
require 'cucumber/rake/task'
# require 'yard'

require 'bundler'
Bundler::GemHelper.install_tasks :name => GEM_NAME

# Skip the releasing tag
class Bundler::GemHelper
  def release_gem
    guard_clean
    # guard_already_tagged
    built_gem_path = build_gem
    rubygem_push(built_gem_path)
  end
end

Cucumber::Rake::Task.new(:test, 'Run features that should pass') do |t|
  t.cucumber_opts = "--color --tags ~@wip --strict --format #{ENV['CUCUMBER_FORMAT'] || 'pretty'}"
end

# YARD::Rake::YardocTask.new

task :default => :test