ENV["TEST"] = "true"
require "datadog/ci"

require "sassc"

require "simplecov"
SimpleCov.root(File.expand_path(File.dirname(__FILE__) + "/../.."))

SimpleCov.start

PROJECT_ROOT_PATH = File.dirname(__FILE__, 3)
require File.join(PROJECT_ROOT_PATH, "lib", "middleman-core")
require File.join(PROJECT_ROOT_PATH, "lib", "middleman-core", "step_definitions")

Datadog.configure do |c|
  c.service = "middleman"
  c.ci.enabled = true
  c.ci.experimental_test_suite_level_visibility_enabled = true
  c.ci.instrument :cucumber
end
