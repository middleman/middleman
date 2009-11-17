#!/usr/bin/env ruby
$:.unshift "../lib"

Dir.chdir File.dirname(__FILE__)
Dir["**/tc_*.rb"].each { |file| load file }
