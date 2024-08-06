require "simplecov"
SimpleCov.root(File.expand_path(File.dirname(__FILE__) + "/.."))
SimpleCov.start

require "datadog/ci"
require "aruba/api"

require_relative "support/given"

Datadog.configure do |c|
  c.service = "middleman"
  c.ci.enabled = true
  c.ci.instrument :rspec
end

require 'rspec/fortify'

# encoding: utf-8
RSpec.configure do |config|
  config.include Aruba::Api

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.default_formatter = "doc" if config.files_to_run.one?

  #  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.retry_on_failure = true
  config.retry_on_failure_count = 5
end
