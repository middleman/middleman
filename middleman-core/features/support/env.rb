ENV["TEST"] = "true"
ENV["AUTOLOAD_SPROCKETS"] ||= "false"
ENV["AUTOLOAD_COMPASS"] ||= "false"

require 'simplecov'
SimpleCov.root(File.expand_path(File.dirname(__FILE__) + '/../..'))

require 'coveralls'
Coveralls.wear!

PROJECT_ROOT_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))
require File.join(PROJECT_ROOT_PATH, 'lib', 'middleman-core')
require File.join(PROJECT_ROOT_PATH, 'lib', 'middleman-core', 'step_definitions')
