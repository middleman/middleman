require 'rake'
require 'yard'

require 'bundler/gem_tasks'

# Skip the releasing tag
# class Bundler::GemHelper
#   def release_gem(*args)
#     p args
#     guard_clean
#     built_gem_path = build_gem
#     rubygem_push(built_gem_path)
#   end
# end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new do |t|
  exempt_tags = ["--tags 'not @wip'"]
  exempt_tags << "--tags 'not @nojava'" if RUBY_PLATFORM == 'java'
  exempt_tags << "--tags 'not @encoding'" unless Object.const_defined?(:Encoding)
  exempt_tags << "--tags 'not @nowindows'" if Gem.win_platform?
  t.cucumber_opts = "--require features --color #{exempt_tags.join(' ')} --strict" # --format #{ENV['CUCUMBER_FORMAT'] || 'Fivemat'}"
end

Cucumber::Rake::Task.new(:cucumber_wip) do |t|
  exempt_tags = ['--tags @wip']
  exempt_tags << '--tags ~@encoding' unless Object.const_defined?(:Encoding)
  exempt_tags << '--tags ~@nowindows' if Gem.win_platform?
  t.cucumber_opts = "--require features --color #{exempt_tags.join(' ')} --strict" # --format #{ENV['CUCUMBER_FORMAT'] || 'Fivemat'}"
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
