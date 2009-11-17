require 'rubygems'
require 'test/unit'

require "#{File.dirname(__FILE__)}/../../vendor/bundler_gems/environment"

require 'shoulda'
begin
  require 'redgreen'
rescue LoadError
end
require 'active_support'
require 'active_support/test_case'
require 'fakeweb'
require 'rr'

FakeWeb.allow_net_connect = false

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), ".."))

require "rubygems_plugin"

class CommandTest < ActiveSupport::TestCase
  include RR::Adapters::TestUnit unless include?(RR::Adapters::TestUnit)
end
