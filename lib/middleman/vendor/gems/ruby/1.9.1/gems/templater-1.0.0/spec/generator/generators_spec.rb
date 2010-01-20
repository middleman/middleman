require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '.generators' do

  before do
    @generator_class = Class.new(Templater::Generator)
    
    @g1 = Class.new(Templater::Generator)
    @g2 = Class.new(Templater::Generator)
    @g3 = Class.new(Templater::Generator)
    @g4 = Class.new(Templater::Generator)

    @manifold = mock('a manifold')
    @manifold.stub!(:generator).with(:monkey).and_return(@g1)
    @manifold.stub!(:generator).with(:blah).and_return(@g2)
    @manifold.stub!(:generator).with(:duck).and_return(@g3)
    @manifold.stub!(:generator).with(:llama).and_return(@g4)
    @manifold.stub!(:generator).with(:i_dont_exist).and_return(nil)

    @generator_class.manifold = @manifold
    @g1.manifold = @manifold
    @g2.manifold = @manifold
    @g3.manifold = @manifold
    @g4.manifold = @manifold
  end

  it "should return [self] when no manifold or invocations exist" do
    @generator_class.manifold = nil
    @generator_class.generators.should == [@generator_class]
  end
  
  it "should return [self] when only invocations exist" do
    @generator_class.manifold = nil
    @generator_class.invoke(:monkey)
    @generator_class.invoke(:blah)
    @generator_class.generators.should == [@generator_class]
  end
  
  it "should return a list of invoked generators" do        
    @generator_class.invoke(:monkey)
    @generator_class.invoke(:blah)
    
    @generator_class.generators.should == [@generator_class, @g1, @g2]
  end
  
  it "should return a list of invoked generators recursively" do
    @generator_class.invoke(:monkey)
    @generator_class.invoke(:blah)
    @g1.invoke(:duck)
    @g3.invoke(:llama)
    
    @generator_class.generators.should == [@generator_class, @g1, @g3, @g4, @g2]
  end
  
  it "should ignore invocations that do not exist in the manifold" do
    @generator_class.invoke(:monkey)
    @generator_class.invoke(:blah)
    @g1.invoke(:duck)
    @g3.invoke(:i_dont_exist)
    
    @generator_class.generators.should == [@generator_class, @g1, @g3, @g2]
  end
end
