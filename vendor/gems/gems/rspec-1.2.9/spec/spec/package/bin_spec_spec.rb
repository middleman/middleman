require 'spec_helper'
require 'ruby_forker'

describe "The bin/spec script" do
  include RubyForker
  
  it "should have no warnings" do
    output = ruby "-w -Ilib bin/spec --help"
    output.should_not =~ /warning/n
  end
  
  it "should show the help w/ no args" do
    output = ruby "-w -Ilib bin/spec"
    output.should =~ /^Usage: spec/
  end
end
