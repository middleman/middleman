require 'spec_helper'
begin
  require 'autotest'
rescue LoadError
  raise "You must install ZenTest to use autotest"
end
require 'autotest/rspec'
require 'spec/autotest/autotest_matchers'
