require "rubygems"
require "rake/rdoctask"
require "rake/gempackagetask"
require "rake/clean"
require "spec/rake/spectask"
require File.expand_path("./lib/rack/test")

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
end

desc "Run all specs in spec directory with RCov"
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
  t.rcov = true
  t.rcov_opts = lambda do
    IO.readlines(File.dirname(__FILE__) + "/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
  end
end

desc "Run the specs"
task :default => :spec

spec = Gem::Specification.new do |s|
  s.name         = "rack-test"
  s.version      = Rack::Test::VERSION
  s.author       = "Bryan Helmkamp"
  s.email        = "bryan" + "@" + "brynary.com"
  s.homepage     = "http://github.com/brynary/rack-test"
  s.summary      = "Simple testing API built on Rack"
  s.description  = s.summary
  s.files        = %w[History.txt Rakefile README.rdoc] + Dir["lib/**/*"]

  # rdoc
  s.has_rdoc         = true
  s.extra_rdoc_files = %w(README.rdoc MIT-LICENSE.txt)
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

desc "Delete generated RDoc"
task :clobber_docs do
  FileUtils.rm_rf("doc")
end

desc "Generate RDoc"
task :docs => :clobber_docs do
  system "hanna --title 'Rack::Test #{Rack::Test::VERSION} API Documentation'"
end

desc 'Install the package as a gem.'
task :install => [:clean, :package] do
  gem = Dir['pkg/*.gem'].first
  sh "sudo gem install --no-rdoc --no-ri --local #{gem}"
end

desc 'Removes trailing whitespace'
task :whitespace do
  sh %{find . -name '*.rb' -exec sed -i '' 's/ *$//g' {} \\;}
end
