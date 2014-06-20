require 'simplecov'
SimpleCov.root(File.expand_path(File.dirname(__FILE__) + '/..'))

require 'coveralls'
Coveralls.wear!

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start