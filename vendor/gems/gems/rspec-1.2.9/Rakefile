# -*- ruby -*-
gem 'hoe', '>=2.0.0'
require 'hoe'

$:.unshift 'lib'

require 'spec/version'
require 'spec/rake/spectask'
require 'spec/ruby'
require 'cucumber/rake/task'

Hoe.spec 'rspec' do
  self.version = Spec::VERSION::STRING
  self.summary = Spec::VERSION::SUMMARY
  self.description = "Behaviour Driven Development for Ruby."
  self.rubyforge_name = 'rspec'
  self.developer('RSpec Development Team', 'rspec-devel@rubyforge.org')
  self.extra_dev_deps << ["cucumber",">=0.3"] << ["bmabey-fakefs",">=0.1.1"] << ["syntax",">=1.0"] << ["diff-lcs",">=1.1.2"]
  self.extra_dev_deps << ["heckle",">=1.4.3"] unless Spec::Ruby.version >= "1.9"
  self.remote_rdoc_dir = "rspec/#{Spec::VERSION::STRING}"
  self.rspec_options = ['--options', 'spec/spec.opts']
  self.history_file = 'History.rdoc'
  self.readme_file  = 'README.rdoc'
  self.post_install_message = <<-POST_INSTALL_MESSAGE
#{'*'*50}

  Thank you for installing rspec-#{Spec::VERSION::STRING}

  Please be sure to read History.rdoc and Upgrade.rdoc
  for useful information about this release.

#{'*'*50}
POST_INSTALL_MESSAGE
end

['audit','test','test_deps','default','post_blog'].each do |task|
  Rake.application.instance_variable_get('@tasks').delete(task)
end

task :post_blog do
  # no-op
end

# Some of the tasks are in separate files since they are also part of the website documentation
load 'resources/rake/examples.rake'
load 'resources/rake/examples_with_rcov.rake'
load 'resources/rake/failing_examples_with_html.rake'
load 'resources/rake/verify_rcov.rake'

task :cleanup_rcov_files do
  rm_rf 'coverage.data'
end


if RUBY_VERSION =~ /^1.8/
  task :default => [:cleanup_rcov_files, :features, :verify_rcov]
else
  task :default => [:spec, :features]
end

namespace :spec do

  desc "Run all specs with rcov"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = ['--options', 'spec/spec.opts']
    t.rcov = true
    t.rcov_dir = 'coverage'
    t.rcov_opts = ['--exclude', "features,kernel,load-diff-lcs\.rb,instance_exec\.rb,lib/spec.rb,lib/spec/runner.rb,^spec/*,bin/spec,examples,/gems,/Library/Ruby,\.autotest,#{ENV['GEM_HOME']}"]
    t.rcov_opts << '--sort coverage --text-summary --aggregate coverage.data'
  end
  
  desc "Run files listed in spec/spec_files.txt"
  Spec::Rake::SpecTask.new(:focus) do |t|
    if File.exists?('spec/spec_files.txt')
      t.spec_files = File.readlines('spec/spec_files.txt').collect{|f| f.chomp}
    end
  end
end

desc "Run Cucumber features"
if RUBY_VERSION =~ /^1.8/
  Cucumber::Rake::Task.new :features do |t|
    t.rcov = true
    t.rcov_opts = ['--exclude', "features,kernel,load-diff-lcs\.rb,instance_exec\.rb,lib/spec.rb,lib/spec/runner.rb,^spec/*,bin/spec,examples,/gems,/Library/Ruby,\.autotest,#{ENV['GEM_HOME']}"]
    t.rcov_opts << '--no-html --aggregate coverage.data'
    t.cucumber_opts = %w{--format progress}
  end
else
  task :features do
    sh 'cucumber --profile no_heckle'
  end
end

desc "Run failing examples (see failure output)"
Spec::Rake::SpecTask.new('failing_examples') do |t|
  t.spec_files = FileList['failing_examples/**/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
end

def egrep(pattern)
  Dir['**/*.rb'].each do |fn|
    count = 0
    open(fn) do |f|
      while line = f.gets
        count += 1
        if line =~ pattern
          puts "#{fn}:#{count}:#{line}"
        end
      end
    end
  end
end

desc "Look for TODO and FIXME tags in the code"
task :todo do
  egrep /(FIXME|TODO|TBD)/
end

desc "verify_committed, verify_rcov, post_news, release"
task :complete_release => [:verify_committed, :verify_rcov, :post_news, :release]

desc "Verifies that there is no uncommitted code"
task :verify_committed do
  IO.popen('git status') do |io|
    io.each_line do |line|
      raise "\n!!! Do a git commit first !!!\n\n" if line =~ /^#\s*modified:/
    end
  end
end

namespace :update do
  desc "update the manifest"
  task :manifest do
    system %q[touch Manifest.txt; rake check_manifest | grep -v "(in " | patch]
  end
end

task :clobber => :clobber_tmp

task :clobber_tmp do
  cmd = %q[rm -r tmp]
  puts cmd
  system cmd if test ?d, 'tmp'
end
