ENV["TEST"] = "true"

require 'sass-embedded'

require 'simplecov'
SimpleCov.root(File.expand_path(File.dirname(__FILE__) + '/../..'))

SimpleCov.start

PROJECT_ROOT_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))
require File.join(PROJECT_ROOT_PATH, 'lib', 'middleman-cli')
require File.join(File.dirname(PROJECT_ROOT_PATH), 'middleman-core', 'lib', 'middleman-core', 'step_definitions')
