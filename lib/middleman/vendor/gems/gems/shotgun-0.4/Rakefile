require 'rake/clean'
require 'rake/testtask'

task :default => [:test]
task :spec => :test

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/spec_*.rb']
  t.ruby_opts = ['-rubygems'] if defined? Gem
end

$spec =
  begin
    require 'rubygems/specification'
    data = File.read('shotgun.gemspec')
    spec = nil
    Thread.new { spec = eval("$SAFE = 3\n#{data}") }.join
    spec
  end

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

desc 'Publish gem and tarball to rubyforge'
task 'release' => [package('.gem'), package('.tar.gz')] do |t|
  sh <<-end
    rubyforge add_release wink #{$spec.name} #{$spec.version} #{package('.gem')} &&
    rubyforge add_file    wink #{$spec.name} #{$spec.version} #{package('.tar.gz')}
  end
end
