ENV["TEST"] = "true"

require "sassc"

require "simplecov"
SimpleCov.root(File.expand_path(File.dirname(__FILE__) + "/../.."))

SimpleCov.start

PROJECT_ROOT_PATH = File.dirname(__FILE__, 3)
require File.join(PROJECT_ROOT_PATH, "lib", "middleman-core")
require File.join(PROJECT_ROOT_PATH, "lib", "middleman-core", "step_definitions")
