require 'bundler'
Bundler::GemHelper.install_tasks

require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:cucumber, 'Run features that should pass') do |t|
  t.cucumber_opts = "--drb --color --tags ~@wip --strict --format #{ENV['CUCUMBER_FORMAT'] || 'pretty'}"
end

namespace :spork do
 desc "start spork in background"
 task :start do
   sh %{spork &}
 end

 desc "stop spork"
 task :stop do
   Process.kill(:TERM, `ps -ef | grep spork | grep -v grep | awk '{ print $2 }'`.to_i)
 end
end

#$LOAD_PATH.unshift 'lib'

require 'rake/testtask'
require 'rake/clean'

task :test => ["spork:start", "cucumber", "spork:stop"]

# rocco depends on rdiscount, which makes me sad.
unless defined?(JRUBY_VERSION)
  # Bring in Rocco tasks
  require 'rocco/tasks'
  Rocco::make 'docs/'

  desc 'Build rocco docs'
  task :docs => :rocco
  directory 'docs/'

  # Make index.html a copy of rocco.html
  file 'docs/index.html' => 'docs/middleman.html' do |f|
    cp 'docs/middleman.html', 'docs/index.html', :preserve => true
  end
  task :docs => 'docs/index.html'
  CLEAN.include 'docs/index.html'

  desc 'Update gh-pages branch'
  task :pages => ['docs/.git', :docs] do
    rev = `git rev-parse --short HEAD`.strip
    Dir.chdir 'docs' do
      sh "git add *.html"
      sh "git commit -m 'rebuild pages from #{rev}'" do |ok,res|
        if ok
          verbose { puts "gh-pages updated" }
          sh "git push -q o HEAD:gh-pages"
        end
      end
    end
  end

  # Update the pages/ directory clone
  file 'docs/.git' => ['docs/', '.git/refs/heads/gh-pages'] do |f|
    sh "cd docs && git init -q && git remote add o ../.git" if !File.exist?(f.name)
    sh "cd docs && git fetch -q o && git reset -q --hard o/gh-pages && touch ."
  end
  CLOBBER.include 'docs/.git'
end
