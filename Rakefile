# frozen_string_literal: true

require 'rake'

require File.expand_path('middleman-core/lib/middleman-core/version.rb', __dir__)

ROOT = __dir__
GEM_NAME = 'middleman'

middleman_gems = %w[middleman-core middleman-cli middleman]
GEM_PATHS = middleman_gems.freeze

def sh_rake(command)
  sh "#{Gem.ruby} -S rake #{command}", verbose: true
end

desc 'Displays the current version'
task :version do
  puts "Current version: #{Middleman::VERSION}"
end

desc 'Pushes repository to GitHub'
task :push do
  puts 'Pushing to github...'
  sh "git tag v#{Middleman::VERSION}"
  sh 'git push'
  sh "git push origin v#{Middleman::VERSION}"
end

desc 'Release all middleman gems'
task publish: :push do
  puts 'Pushing to rubygems...'
  GEM_PATHS.each do |dir|
    Dir.chdir(dir) { sh_rake('release') }
  end
end

desc 'Generate documentation for all middleman gems'
task :doc do
  GEM_PATHS.each do |g|
    Dir.chdir(File.join(ROOT, g).to_s) { sh "#{Gem.ruby} -S rake yard" }
  end
end

desc 'Run tests for all middleman gems'
task :test do
  Rake::Task['rubocop'].invoke

  GEM_PATHS.each do |g|
    Dir.chdir(File.join(ROOT, g).to_s) { sh "#{Gem.ruby} -S rake test" }
  end
end

desc 'Run specs for all middleman gems'
task :spec do
  GEM_PATHS.each do |g|
    Dir.chdir(File.join(ROOT, g).to_s) { sh "#{Gem.ruby} -S rake spec" }
  end
end

require 'rubocop/rake_task'
desc 'Run RuboCop to check code consistency'
RuboCop::RakeTask.new(:rubocop)

desc 'Run tests for all middleman gems'
task default: :test
