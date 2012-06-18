require 'rubygems' unless defined?(Gem)
require 'rake'
require 'cucumber/rake/task'
require 'yard'

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
  exempt_tags = ["--tags ~@wip"]
  exempt_tags << "--tags ~@nojava" if RUBY_PLATFORM == "java"
  exempt_tags << "--tags ~@encoding" unless Object.const_defined?(:Encoding)
  exempt_tags << "--tags ~@travishatesme" if ENV["TRAVIS"] == "true"
  
  t.cucumber_opts = "--color #{exempt_tags.join(" ")} --strict --format #{ENV['CUCUMBER_FORMAT'] || 'Fivemat'}"
end

YARD::Rake::YardocTask.new

task :default => :test