dir = File.dirname(__FILE__)
require 'rubygems'
require 'rake'
$LOAD_PATH.unshift(File.join(dir, 'vendor', 'rspec', 'lib'))
require 'spec/rake/spectask'

require 'rake/gempackagetask'

task :default => :spec

Spec::Rake::SpecTask.new do |t|
  t.pattern = 'spec/**/*spec.rb'
end

load "./treetop.gemspec"

Rake::GemPackageTask.new($gemspec) do |pkg|
  pkg.need_tar = true
end
