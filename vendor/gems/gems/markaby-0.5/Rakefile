require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'tools/rakehelp'
require 'fileutils'
include FileUtils

REV = File.read(".svn/entries")[/committed-rev="(\d+)"/, 1] rescue nil
VERS = ENV['VERSION'] || "0.5" + (REV ? ".#{REV}" : "")

task :default => [:package]

setup_tests
setup_rdoc ['README', 'CHANGELOG', 'lib/**/*.rb']

summary = "Markup as Ruby, write HTML in your native Ruby tongue"
test_file = "test/test_markaby.rb"
setup_gem("markaby", VERS,  "Tim Fletcher and _why", summary, [['builder', '>=2.0.0']], test_file)
