#!/usr/bin/env ruby
require 'pathname'
require 'rubygems'
require 'rubygems/installer'
require 'rake'
require "rake/clean"
require "rake/gempackagetask"
require "fileutils"
require Pathname('spec/rake/spectask')
require Pathname('lib/extlib/version')

ROOT    = Pathname(__FILE__).dirname.expand_path
JRUBY   = RUBY_PLATFORM =~ /java/
WINDOWS = Gem.win_platform?
SUDO    = (WINDOWS || JRUBY) ? '' : ('sudo' unless ENV['SUDOLESS'])

##############################################################################
# Package && release
##############################################################################
RUBY_FORGE_PROJECT  = "extlib"
PROJECT_URL         = "http://extlib.rubyforge.org"
PROJECT_SUMMARY     = "Support library for DataMapper and Merb."
PROJECT_DESCRIPTION = PROJECT_SUMMARY

AUTHOR = "Dan Kubb"
EMAIL  = "dan.kubb@gmail.com"

GEM_NAME    = "extlib"
PKG_BUILD   = ENV['PKG_BUILD'] ? '.' + ENV['PKG_BUILD'] : ''
GEM_VERSION = Extlib::VERSION + PKG_BUILD

RELEASE_NAME = "REL #{GEM_VERSION}"

require "lib/extlib/tasks/release"

spec = Gem::Specification.new do |s|
  s.name         = GEM_NAME
  s.version      = GEM_VERSION
  s.platform     = Gem::Platform::RUBY
  s.author       = AUTHOR
  s.email        = EMAIL
  s.homepage     = PROJECT_URL
  s.summary      = PROJECT_SUMMARY
  s.description  = PROJECT_DESCRIPTION
  s.require_path = 'lib'
  s.files        = %w[ LICENSE README Rakefile History.txt ] + Dir['lib/**/*'] + Dir['spec/**/*']

  # rdoc
  s.has_rdoc         = false
  s.extra_rdoc_files = %w[ LICENSE README History.txt ]

  # Dependencies
  # s.add_dependency "english", ">=0.2.0"
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

desc 'Remove all package, docs and spec products'
task :clobber_all => %w[ clobber_package clobber_doc extlib:clobber_spec ]

##############################################################################
# Specs and continous integration
##############################################################################
task :default => 'extlib:spec'
task :spec    => 'extlib:spec'

namespace :extlib do
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_opts << '--options' << ROOT + 'spec/spec.opts'
    t.spec_files = Pathname.glob(ENV['FILES'] || 'spec/**/*_spec.rb').map { |f| f.to_s }
    t.libs << 'lib'
    begin
      gem 'rcov'
      t.rcov = JRUBY ? false : (ENV.has_key?('NO_RCOV') ? ENV['NO_RCOV'] != 'true' : true)
      t.rcov_opts << '--exclude' << 'spec'
      t.rcov_opts << '--text-summary'
      t.rcov_opts << '--sort' << 'coverage' << '--sort-reverse'
    rescue LoadError
      # rcov not installed
    end
  end
end


##############################################################################
# Documentation
##############################################################################
desc "Generate documentation"
task :doc do
  begin
    require 'yard'
    exec 'yardoc'
  rescue LoadError
    puts 'You will need to install the latest version of Yard to generate the
          documentation for extlib.'
  end
end

def sudo_gem(cmd)
  sh "#{SUDO} #{RUBY} -S gem #{cmd}", :verbose => false
end

desc "Install #{GEM_NAME}"
task :install => :package do
  sudo_gem "install --local pkg/#{GEM_NAME}-#{GEM_VERSION}"
end

if WINDOWS
  namespace :dev do
    desc 'Install for development (for Windows)'
    task :winstall => :gem do
      system %{gem install --no-rdoc --no-ri -l pkg/#{GEM_NAME}-#{GEM_VERSION}.gem}
    end
  end
end

namespace :ci do

  task :prepare do
    rm_rf ROOT + "ci"
    mkdir_p ROOT + "ci"
    mkdir_p ROOT + "ci/doc"
    mkdir_p ROOT + "ci/cyclomatic"
    mkdir_p ROOT + "ci/token"
  end

  task :publish do
    out = ENV['CC_BUILD_ARTIFACTS'] || "out"
    mkdir_p out unless File.directory? out

    mv "ci/rspec_report.html", "#{out}/rspec_report.html"
    mv "ci/coverage", "#{out}/coverage"
    mv "ci/doc", "#{out}/doc"
    mv "ci/cyclomatic", "#{out}/cyclomatic_complexity"
    mv "ci/token", "#{out}/token_complexity"
  end

  task :spec => :prepare do
    Rake::Task[:spec].invoke
    mv ROOT + "coverage", ROOT + "ci/coverage"
    Rake::Task[:gem]
    Gem::Installer.new("pkg/#{GEM_NAME}-#{GEM_VERSION}.gem").install
  end

  task :doc do
    require 'yard'
    sh 'yardoc'
  end

  task :saikuro do
    system "saikuro -c -i lib -y 0 -w 10 -e 15 -o ci/cyclomatic"
    mv 'ci/cyclomatic/index_cyclo.html', 'ci/cyclomatic/index.html'

    system "saikuro -t -i lib -y 0 -w 20 -e 30 -o ci/token"
    mv 'ci/token/index_token.html', 'ci/token/index.html'
  end

end

task :ci => ["ci:spec"]

desc 'Default: run spec examples'
task :default => 'spec'

##############################################################################
# Benchmarks
##############################################################################

namespace :benchmark do
  desc "Runs benchmarks"
  task :run do
    files = Dir["benchmarks/**/*.rb"]

    files.each do |f|
      system "ruby #{f}"
    end
  end
end
