require 'rake'

require 'middleman-core/version'

def sh_rake(command)
  sh "#{Gem.ruby} -S rake #{command}", verbose: true
end

def within_each_gem(&block)
  %w(middleman-core middleman).each do |dir|
    Dir.chdir(dir) { block.call }
  end
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
  within_each_gem { sh_rake('release') }
end

desc 'Generate documentation for all middleman gems'
task :doc do
  within_each_gem { sh_rake('yard') }
end

desc 'Run tests for all middleman gems'
task :test do
  Rake::Task['rubocop'].invoke
  within_each_gem { sh_rake('test') }
end

desc 'Run specs for all middleman gems'
task :spec do
  within_each_gem { sh_rake('spec') }
end

require 'rubocop/rake_task'
desc 'Run RuboCop to check code consistency'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = false
end

desc 'Run tests for all middleman gems'
task default: :test
