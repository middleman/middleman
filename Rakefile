require 'rubygems'  unless defined?(Gem)
# require 'fileutils' unless defined?(FileUtils)
require 'rake'
require 'yard'

require File.expand_path("../middleman-core/lib/middleman-core/version.rb", __FILE__)

ROOT = File.expand_path(File.dirname(__FILE__))
GEM_NAME = 'middleman'

middleman_gems = %w(middleman-core middleman-more)
GEM_PATHS = middleman_gems.freeze

def sh_rake(command)
  sh "#{Gem.ruby} -S rake #{command}", :verbose => true
end

def say(text, color=:magenta)
  n = { :bold => 1, :red => 31, :green => 32, :yellow => 33, :blue => 34, :magenta => 35 }.fetch(color, 0)
  puts "\e[%dm%s\e[0m" % [n, text]
end
  
desc "Run 'install' for all projects"
task :install do
  GEM_PATHS.each do |dir|
    Dir.chdir(dir) { sh_rake(:install) }
  end
end

desc "Clean pkg and other stuff"
task :clean do
  GEM_PATHS.each do |g|
    %w[tmp pkg coverage].each { |dir| sh 'rm -rf %s' % File.join(g, dir) }
  end
end

desc "Clean pkg and other stuff"
task :uninstall do
  sh "gem search --no-version middleman | grep middleman | xargs gem uninstall -a"
end

desc "Displays the current version"
task :version do
  say "Current version: #{Middleman::VERSION}"
end

desc "Bumps the version number based on given version"
task :bump, [:version] do |t, args|
  raise "Please specify version=x.x.x !" unless args.version
  version_path = File.dirname(__FILE__) + '/middleman-core/lib/middleman-core/version.rb'
  version_text = File.read(version_path).sub(/VERSION = '[\d\.\w]+'/, "VERSION = '#{args.version}'")
  say "Updating Middleman to version #{args.version}"
  $stderr.puts version_path, version_text
  File.open(version_path, 'w') { |f| f.write version_text }
  sh 'git commit -a -m "Bumped version to %s"' % args.version
end

desc "Executes a fresh install removing all middleman version and then reinstall all gems"
task :fresh => [:uninstall, :install, :clean]

desc "Pushes repository to GitHub"
task :push do
  say "Pushing to github..."
  sh "git tag v#{Middleman::VERSION}"
  sh "git push origin master"
  sh "git push origin v#{Middleman::VERSION}"
end

desc "Release all middleman gems"
task :publish => :push do
  say "Pushing to rubygems..."
  GEM_PATHS.each do |dir|
    Dir.chdir(dir) { sh_rake("release") }
  end
  Rake::Task["clean"].invoke
end

desc "Run tests for all middleman gems"
task :test do
  GEM_PATHS.each do |g|
    sh "cd #{File.join(ROOT, g)} && #{Gem.ruby} -S rake test"
  end
end

desc "Run tests for all middleman gems"
task :default => :test

desc "Generate documentation"
task :doc do
  YARD::CLI::Yardoc.new.run
end