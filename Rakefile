require 'rubygems'  unless defined?(Gem)
# require 'fileutils' unless defined?(FileUtils)
require 'rake'
require 'yard'

require File.expand_path("../middleman-core/lib/middleman-core/version.rb", __FILE__)

ROOT = File.expand_path(File.dirname(__FILE__))
GEM_NAME = 'middleman'

middleman_gems = %w(middleman-core middleman-more middleman)
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

desc "Build vendored gems"
task :build_vendor do
  raise unless File.exist?('Rakefile')

  # Destroy vendor
  sh "rm -rf middleman-core/lib/vendor/darwin"
  sh "rm -rf middleman-core/lib/vendor/linux"

  # Clone the correct gems
  sh "git clone https://github.com/thibaudgg/rb-fsevent.git middleman-core/lib/vendor/darwin"
  sh "cd middleman-core/lib/vendor/darwin && git checkout 1ca42b987596f350ee7b19d8f8210b7b6ae8766b"
  sh "git clone https://github.com/nex3/rb-inotify.git middleman-core/lib/vendor/linux"
  sh "cd middleman-core/lib/vendor/linux && git checkout 01e7487e7a8d8f26b13c6835a321390c6618ccb7"

  # Strip out the .git directories
  %w[darwin linux].each {|platform| sh "rm -rf middleman-core/lib/vendor/#{platform}/.git"}

  # Move ext directory of darwin to root
  sh "mkdir -p ext"
  sh "cp -r middleman-core/lib/vendor/darwin/ext/* ext/"

  # Alter darwin extconf.rb
  extconf_path = File.expand_path("../ext/extconf.rb", __FILE__)
  extconf_contents = File.read(extconf_path)
  extconf_contents.sub!(/puts "Warning/, '#\0')
  extconf_contents.gsub!(/bin\/fsevent_watch/, 'bin/fsevent_watch_guard')
  File.open(extconf_path, 'w') { |f| f << extconf_contents }

  # Alter lib/vendor/darwin/lib/rb-fsevent/fsevent.rb
  fsevent_path = File.expand_path("../middleman-core/lib/vendor/darwin/lib/rb-fsevent/fsevent.rb", __FILE__)
  fsevent_contents = File.read(fsevent_path)
  fsevent_contents.sub!(/fsevent_watch/, 'fsevent_watch_guard')
  fsevent_contents.sub!(/'\.\.'/, "'..', '..', '..', '..'")

  File.open(fsevent_path, 'w') { |f| f << fsevent_contents }
end

desc "Compile mac executable"
task :build_mac_exec do
  Dir.chdir(File.expand_path("../ext", __FILE__)) do
    system("ruby extconf.rb") or raise
  end
end