ENV["MM_DIR"] = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "spec", "fixtures", "sample")
require File.join(File.dirname(File.dirname(File.dirname(__FILE__))), 'lib', 'middleman')
require "rack/test"