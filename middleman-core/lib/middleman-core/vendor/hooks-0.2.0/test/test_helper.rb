require 'rubygems'

# wycats says...
require 'bundler'
Bundler.setup
require 'test/unit'
require 'shoulda'
require 'hooks'

$:.unshift File.dirname(__FILE__) # add current dir to LOAD_PATHS
