require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '.option' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should add accessors" do
    @generator_class.option(:test)

    instance = @generator_class.new('/tmp')
    
    instance.test = "monkey"
    instance.test.should == "monkey"
    
  end
  
  it "should preset a default value" do
    @generator_class.option(:test, :default => 'elephant')

    instance = @generator_class.new('/tmp')
  
    instance.test.should == "elephant"  
  end
  
  it "should allow overwriting of default values" do
    @generator_class.option(:test, :default => 'elephant')

    instance = @generator_class.new('/tmp')
  
    instance.test.should == "elephant"  
    instance.test = "monkey"  
    instance.test.should == "monkey"  
  end
  
  it "should allow passing in of options on generator creation" do
    @generator_class.option(:test, :default => 'elephant')

    instance = @generator_class.new('/tmp', { :test => 'freebird' })
  
    instance.test.should == "freebird"  
    instance.test = "monkey"  
    instance.test.should == "monkey"  
  end
end
