# frozen_string_literal: true

require 'rake'
require 'yard'

require 'bundler/gem_tasks'

# Skip the releasing tag
class Bundler::GemHelper
  def release_gem(*args)
    p args
    guard_clean
    built_gem_path = build_gem
    rubygem_push(built_gem_path)
  end
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new do |t|
  exempt_tags = if Gem.win_platform?
                  ["--tags 'not(@wip or @skip-windows)'"]
                else
                  ["--tags 'not @wip'"]
                end
  t.cucumber_opts = "--fail-fast --require features --color #{exempt_tags.join(' ')} --strict"
end

Cucumber::Rake::Task.new(:cucumber_wip) do |t|
  exempt_tags = ['--tags @wip']
  t.cucumber_opts = "--fail-fast --require features --color #{exempt_tags.join(' ')} --strict"
end

require 'rspec/core/rake_task'
desc 'Run RSpec'
RSpec::Core::RakeTask.new do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['--color', '--format documentation']
end

desc 'Run tests, both RSpec and Cucumber'
task test: %i[spec cucumber]

YARD::Rake::YardocTask.new

task default: :test
