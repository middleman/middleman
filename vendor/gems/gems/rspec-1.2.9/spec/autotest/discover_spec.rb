require 'spec/autotest/autotest_helper'

describe Autotest::Rspec, "discovery" do
  it "adds the rspec autotest plugin" do
    Autotest.should_receive(:add_discovery)
    load File.expand_path(File.dirname(__FILE__) + "/../../lib/autotest/discover.rb")
  end
end  
