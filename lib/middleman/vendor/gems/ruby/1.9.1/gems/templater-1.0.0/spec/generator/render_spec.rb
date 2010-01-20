require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '#render!' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should render all actions and return an array of the results" do
    template1 = mock('a template')
    template2 = mock('another template')
    
    instance = @generator_class.new('/tmp')
    
    instance.should_receive(:actions).and_return([template1, template2])
    template1.should_receive(:render).and_return("oh my")
    template2.should_receive(:render).and_return("monkey")

    instance.render!.should == ["oh my", "monkey"]
  end
end
