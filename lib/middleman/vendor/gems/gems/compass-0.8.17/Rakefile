if ENV['RUN_CODE_RUN']
  # We need to checkout edge haml for the run>code>run test environment.
  if File.directory?("haml")
    Dir.chdir("haml") do
      sh "git", "pull"
    end
  else
    sh "git", "clone", "git://github.com/nex3/haml.git"
  end
  $LOAD_PATH.unshift "haml/lib"
end

require 'rubygems'
require 'rake'
require 'lib/compass'

# ----- Default: Testing ------

task :default => :run_tests

require 'rake/testtask'
require 'fileutils'

Rake::TestTask.new :run_tests do |t|
  t.libs << 'lib'
  t.libs << 'haml/lib' if ENV["RUN_CODE_RUN"]
  test_files = FileList['test/**/*_test.rb']
  test_files.exclude('test/rails/*', 'test/haml/*')
  t.test_files = test_files
  t.verbose = true
end
Rake::Task[:test].send(:add_comment, <<END)
To run with an alternate version of Rails, make test/rails a symlink to that version.
To run with an alternate version of Haml & Sass, make test/haml a symlink to that version.
END

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.rubyforge_project = "compass"
    gemspec.name = "compass"
    gemspec.summary = "A Real Stylesheet Framework"
    gemspec.email = "chris@eppsteins.net"
    gemspec.homepage = "http://compass-style.org"
    gemspec.description = "Compass is a Sass-based Stylesheet Framework that streamlines the creation and maintainance of CSS."
    gemspec.authors = ["Chris Eppstein"]
    gemspec.has_rdoc = false
    gemspec.add_dependency('haml', '>= 2.2.0')
    gemspec.files = []
    gemspec.files << "CHANGELOG.markdown"
    gemspec.files << "README.markdown"
    gemspec.files << "LICENSE.markdown"
    gemspec.files << "REVISION"
    gemspec.files << "VERSION.yml"
    gemspec.files << "Rakefile"
    gemspec.files << "deps.rip"
    gemspec.files += Dir.glob("bin/*")
    gemspec.files += Dir.glob("examples/**/*.*")
    gemspec.files -= Dir.glob("examples/**/*.css")
    gemspec.files -= Dir.glob("examples/**/*.html")
    gemspec.files += Dir.glob("frameworks/**/*.*")
    gemspec.files += Dir.glob("lib/**/*")
    gemspec.files += Dir.glob("test/**/*.*")
    gemspec.files -= Dir.glob("test/fixtures/stylesheets/*/saved/**/*.*")
    gemspec.test_files = Dir.glob("test/**/*.*")
    gemspec.test_files -= Dir.glob("test/fixtures/stylesheets/*/saved/**/*.*")
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc "Record the current git revision."
task :REVISION do
  require 'git'
  
  repo = Git.open('.')
  open("REVISION", "w") do |f|
    f.write(repo.object("HEAD").sha)
  end
end

desc "Commit the revision file."
task :commit_revision => :REVISION do
  require 'git'
  repo = Git.open('.')  
  repo.add("REVISION")
  repo.commit("Record current revision for release.")
end

task :release => :commit_revision

desc "Compile Examples into HTML and CSS"
task :examples do
  linked_haml = "tests/haml"
  if File.exists?(linked_haml) && !$:.include?(linked_haml + '/lib')
    puts "[ using linked Haml ]"
    $:.unshift linked_haml + '/lib'
  end
  require 'haml'
  require 'sass'
  require 'pathname'
  require 'lib/compass'
  require 'lib/compass/exec'
  FileList['examples/*'].each do |example|
    next unless File.directory?(example)
    puts "\nCompiling #{example}"
    puts "=" * "Compiling #{example}".length
    # compile any haml templates to html
    FileList["#{example}/**/*.haml"].each do |haml_file|
      basename = haml_file[0..-6]
      engine = Haml::Engine.new(open(haml_file).read, :filename => haml_file)
      puts "     haml #{File.basename(basename)}"
      output = open(basename,'w')
      output.write(engine.render)
      output.close
    end
    Dir.chdir example do
      Compass::Exec::Compass.new(["--force"]).run!
    end
  end
end

namespace :git do
  task :clean do
    sh "git", "clean", "-fdx"
  end
end
