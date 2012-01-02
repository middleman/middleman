require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rb-inotify"
    gem.summary = "A Ruby wrapper for Linux's inotify, using FFI"
    gem.description = gem.summary
    gem.email = "nex342@gmail.com"
    gem.homepage = "http://github.com/nex3/rb-inotify"
    gem.authors = ["Nathan Weizenbaum"]
    gem.add_dependency "ffi", ">= 0.5.0"
    gem.add_development_dependency "yard", ">= 0.4.0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

task(:permissions) {sh %{chmod -R a+r .}}
Rake::Task[:build].prerequisites.unshift('permissions')

module Jeweler::VersionHelper::PlaintextExtension
  def write_with_inotify
    write_without_inotify
    filename = File.join(File.dirname(__FILE__), "lib/rb-inotify.rb")
    text = File.read(filename)
    File.open(filename, 'w') do |f|
      f.write text.gsub(/^(  VERSION = ).*/, '\1' + [major, minor, patch].inspect)
    end
  end
  alias_method :write_without_inotify, :write
  alias_method :write, :write_with_inotify
end

class Jeweler::Commands::Version::Base
  def commit_version_with_inotify
    return unless self.repo
    self.repo.add(File.join(File.dirname(__FILE__), "lib/rb-inotify.rb"))
    commit_version_without_inotify
  end
  alias_method :commit_version_without_inotify, :commit_version
  alias_method :commit_version, :commit_version_with_inotify
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
