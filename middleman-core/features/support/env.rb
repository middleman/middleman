ENV["TEST"] = "true"
ENV["AUTOLOAD_SPROCKETS"] = "false"

if ENV["COVERAGE"] && (RUBY_VERSION =~ /1\.9/ || RUBY_VERSION =~ /2\.0/))
  require 'simplecov'
  SimpleCov.root(File.expand_path(File.dirname(__FILE__) + '/../..'))
  SimpleCov.start do
    add_filter '/features/'
    add_filter '/spec/'
    add_filter '/vendor'
    add_filter '/step_definitions/'
  end
end

PROJECT_ROOT_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))
require File.join(PROJECT_ROOT_PATH, 'lib', 'middleman-core')
require File.join(PROJECT_ROOT_PATH, 'lib', 'middleman-core', 'step_definitions')
