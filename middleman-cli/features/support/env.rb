ENV["TEST"] = "true"

require 'sassc'

require 'simplecov'
SimpleCov.root(File.expand_path(File.dirname(__FILE__) + '/../..'))

require 'phantomjs/poltergeist'
Capybara.javascript_driver = :poltergeist

require 'coveralls'
Coveralls.wear!

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

PROJECT_ROOT_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))
require File.join(PROJECT_ROOT_PATH, 'lib', 'middleman-cli')
require File.join(File.dirname(PROJECT_ROOT_PATH), 'middleman-core', 'lib', 'middleman-core', 'step_definitions')
