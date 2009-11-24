require File.dirname(__FILE__) + '/spec_helper'

describe Templater::Manifold, '#add_public' do

  before(:each) do
    @manifold = class << self; self end
    @manifold.extend Templater::Manifold
    @generator = mock('a generator')
    @generator.stub!(:manifold=)
  end
  
  it "should allow retrieval with #generate" do
    @manifold.add_public(:monkey, @generator)
    @manifold.generator(:monkey).should == @generator
  end
  
  it "should allow retrieval with #generators" do
    @manifold.add_public(:monkey, @generator)
    @manifold.generators[:monkey].should == @generator
  end
  
  it "should allow retrieval with #public_generators" do
    @manifold.add_public(:monkey, @generator)
    @manifold.public_generators[:monkey].should == @generator
  end
  
  it "should not allow retrieval with #private_generators" do
    @manifold.add_public(:monkey, @generator)
    @manifold.private_generators[:monkey].should be_nil
  end
  
  it "should set the manifold for the generator" do
    @generator.should_receive(:manifold=).with(@manifold)
    @manifold.add_public(:monkey, @generator)
  end
  
end

describe Templater::Manifold, '#add' do

  before(:each) do
    @manifold = class << self; self end
    @manifold.extend Templater::Manifold
    @generator = mock('a generator')
    @generator.stub!(:manifold=)
  end
  
  it "should be an alias for #add_public" do
    @generator.should_receive(:manifold=).with(@manifold)
    @manifold.add_public(:monkey, @generator)
    @manifold.generator(:monkey).should == @generator
    @manifold.generators[:monkey].should == @generator
    @manifold.public_generators[:monkey].should == @generator
    @manifold.private_generators[:monkey].should be_nil
  end
  
end

describe Templater::Manifold, '#add_private' do

  before(:each) do
    @manifold = class << self; self end
    @manifold.extend Templater::Manifold
    @generator = mock('a generator')
    @generator.stub!(:manifold=)
  end
  
  it "should allow retrieval with #generate" do
    @manifold.add_private(:monkey, @generator)
    @manifold.generator(:monkey).should == @generator
  end
  
  it "should allow retrieval with #generators" do
    @manifold.add_private(:monkey, @generator)
    @manifold.generators[:monkey].should == @generator
  end
  
  it "should not allow retrieval with #public_generators" do
    @manifold.add_private(:monkey, @generator)
    @manifold.public_generators[:monkey].should be_nil
  end
  
  it "should allow retrieval with #private_generators" do
    @manifold.add_private(:monkey, @generator)
    @manifold.private_generators[:monkey].should == @generator
  end
  
  it "should set the manifold for the generator" do
    @generator.should_receive(:manifold=).with(@manifold)
    @manifold.add_private(:monkey, @generator)
  end
  
end


describe Templater::Manifold, '#remove' do
  
  before(:each) do
    @manifold = class << self; self end
    @manifold.extend Templater::Manifold
    @generator = mock('a generator')
    @generator.stub!(:manifold=)
  end
  
  it "should remove a public generator" do
    @manifold.add(:monkey, @generator)
    @manifold.remove(:monkey)
    @manifold.generator(:monkey).should be_nil
    @manifold.generators[:monkey].should be_nil
    @manifold.public_generators[:monkey].should be_nil
  end
  
  it "should remove a private generator" do
    @manifold.add_private(:monkey, @generator)
    @manifold.remove(:monkey)
    @manifold.generator(:monkey).should be_nil
    @manifold.generators[:monkey].should be_nil
    @manifold.public_generators[:monkey].should be_nil
  end

end

describe Templater::Manifold, '#run_cli' do

  it "should run the command line interface" do
    manifold = class << self; self end
    manifold.extend Templater::Manifold
        
    Templater::CLI::Manifold.should_receive(:run).with('/path/to/destination', manifold, 'gen', '0.3', ['arg', 'blah'])
    
    manifold.run_cli('/path/to/destination', 'gen', '0.3', ['arg', 'blah'])
  end

end

describe Templater::Manifold, '#desc' do

  it "should append text when called with an argument, and return it when called with no argument" do
    manifold = class << self; self end
    manifold.extend Templater::Manifold
    
    manifold.desc "some text"
    manifold.desc.should == "some text"
  end

end