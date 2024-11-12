require 'rake'
require_relative './middleman-core/lib/middleman-core/version'

ROOT = __dir__
GEM_NAME = 'middleman'.freeze
middleman_gems = %w[middleman-core middleman-cli middleman]
GEM_PATHS = middleman_gems.freeze
GEMS_WITH_TESTS = middleman_gems - %w[middleman].freeze

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
  GEMS_WITH_TESTS.each do |g|
    Dir.chdir(File.join(ROOT, g).to_s) { sh "#{Gem.ruby} -S rake test" }
  end
end

desc 'Run specs for all middleman gems'
task :spec do
  GEMS_WITH_TESTS.each do |g|
    Dir.chdir(File.join(ROOT, g).to_s) { sh "#{Gem.ruby} -S rake spec" }
  end
end

desc 'Run tests for all middleman gems'
task default: :test
