require 'rake/clean'
require 'rake/testtask'

task :default => [:test]
task :spec => :test

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/spec_*.rb']
  t.ruby_opts = ['-rubygems'] if defined? Gem
end

require 'rubygems'
$spec = eval(File.read('shotgun.gemspec'))

def package(ext='')
  "pkg/#{$spec.name}-#{$spec.version}" + ext
end

desc 'Build packages'
task :package => %w[.gem .tar.gz].map { |e| package(e) }

desc 'Build and install as local gem'
task :install => package('.gem') do
  sh "gem install #{package('.gem')}"
end

directory 'pkg/'
CLOBBER.include('pkg')

file package('.gem') => %W[pkg/ #{$spec.name}.gemspec] + $spec.files do |f|
  sh "gem build #{$spec.name}.gemspec"
  mv File.basename(f.name), f.name
end

file package('.tar.gz') => %w[pkg/] + $spec.files do |f|
  sh <<-SH
    git archive \
      --prefix=#{$spec.name}-#{$spec.version}/ \
      --format=tar \
      HEAD | gzip > #{f.name}
  SH
end
