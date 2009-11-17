require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '.desc' do
  it "should append text when called with an argument, and return it when called with no argument" do
    @generator_class = Class.new(Templater::Generator)
    
    @generator_class.desc "some text"
    @generator_class.desc.should == "some text"
  end
end
