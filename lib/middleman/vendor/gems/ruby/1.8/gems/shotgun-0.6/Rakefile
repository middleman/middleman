require 'rake/clean'
require 'rake/testtask'

task :default => [:test]
task :spec => :test

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/*_test.rb']
  t.ruby_opts = ['-rubygems'] if defined? Gem
end

if defined? Gem
  $spec = eval(File.read('shotgun.gemspec'))

  def package(ext='')
    "pkg/#{$spec.name}-#{$spec.version}#{ext}"
  end

  desc 'Build packages'
  task :package => %w[.gem .tar.gz].map { |ext| package(ext) }

  desc 'Build and install as local gem'
  task :install => package('.gem') do
    sh "gem install #{package('.gem')}"
  end

  directory 'pkg/'
  CLOBBER.include('pkg')

  file package('.gem') => %w[pkg/ shotgun.gemspec] + $spec.files do |f|
    sh "gem build shotgun.gemspec"
    mv File.basename(f.name), f.name
  end

  file package('.tar.gz') => %w[pkg/] + $spec.files do |f|
    sh <<-SH
      git archive \
        --prefix=shotgun-#{$spec.version}/ \
        --format=tar \
        HEAD | gzip > #{f.name}
    SH
  end
end
