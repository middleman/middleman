ENV['TEST'] = 'true'

require 'backports/latest'
require 'active_support/all'

require 'sassc'

require 'simplecov'
SimpleCov.root(File.expand_path(File.dirname(__FILE__) + '/../..'))

require 'simplecov'
SimpleCov.start

PROJECT_ROOT_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))
require File.join(PROJECT_ROOT_PATH, 'lib', 'middleman-cli')
require File.join(File.dirname(PROJECT_ROOT_PATH), 'middleman-core', 'lib', 'middleman-core', 'step_definitions')
