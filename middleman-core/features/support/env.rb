ENV["TEST"] = "true"

require 'sassc'

require 'simplecov'
SimpleCov.root(File.expand_path(File.dirname(__FILE__) + '/../..'))

require 'phantomjs/poltergeist'
Capybara.javascript_driver = :poltergeist

Capybara.server = :webrick

require 'simplecov'
SimpleCov.start

PROJECT_ROOT_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))
require File.join(PROJECT_ROOT_PATH, 'lib', 'middleman-core')
require File.join(PROJECT_ROOT_PATH, 'lib', 'middleman-core', 'step_definitions')
