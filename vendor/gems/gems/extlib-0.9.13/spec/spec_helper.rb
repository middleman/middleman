$TESTING=true
require "rubygems"
require "spec"
require "yaml"

dir = File.dirname(__FILE__)
lib_path = File.expand_path("#{dir}/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

require 'extlib'
