require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '#invoke!' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should invoke all actions" do
    template1 = mock('a template')
    template2 = mock('another template')
    
    instance = @generator_class.new('/tmp')
    
    instance.should_receive(:actions).and_return([template1, template2])
    template1.should_receive(:invoke!)
    template2.should_receive(:invoke!)

    instance.invoke!
  end
end
