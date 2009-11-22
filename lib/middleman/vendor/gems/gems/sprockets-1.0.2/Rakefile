require "rubygems"
require "rake/testtask"
require "rake/gempackagetask"

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/test_*.rb"]
  t.verbose = true
end

Rake::GemPackageTask.new(eval(IO.read(File.join(File.dirname(__FILE__), "sprockets.gemspec")))) do |pkg|
  require File.join(File.dirname(__FILE__), "lib", "sprockets", "version")
  raise "Error: Sprockets::Version doesn't match gemspec" if Sprockets::Version::STRING != pkg.version.to_s
  
  pkg.need_zip = true
  pkg.need_tar = true
end
