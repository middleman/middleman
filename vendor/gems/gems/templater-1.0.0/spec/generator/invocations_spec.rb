require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '.invoke' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.first_argument :test1
    @generator_class.second_argument :test2
    
    @invoked_generator = mock('an invoked generator')
    @invoked_instance = mock('an instance of the invoked generator')
    @invoked_generator.stub!(:new).and_return(@invoked_instance)
    
    @manifold = mock('a manifold')
    @manifold.stub!(:generator).with(:test).and_return(@invoked_generator)
  end

  it "should add nothing if there is no manifold" do
    @generator_class.invoke(:test)
    @instance = @generator_class.new('/tmp', {}, 'test', 'argument')

    @instance.invocations.should be_empty
  end

  describe "with no block" do
    
    before(:each) do
      @generator_class.stub!(:manifold).and_return(@manifold)
    end
    
    it "should return the instantiaded template" do
      @generator_class.invoke(:test)
      @instance = @generator_class.new('/tmp', {}, 'test', 'argument')

      @instance.invocations.first.should == @invoked_instance
    end
    
    it "should ask the manifold for the generator" do
      @generator_class.should_receive(:manifold).at_least(:once).and_return(@manifold)
      @manifold.should_receive(:generator).with(:test).and_return(@invoked_generator)
      @generator_class.invoke(:test)
      @instance = @generator_class.new('/tmp', {}, 'test', 'argument')
      
      @instance.invocations.first.should == @invoked_instance
    end
    
    it "should instantiate the generator with the correct arguments" do
      @invoked_generator.should_receive(:new).with('/tmp', {}, 'test', 'argument').and_return(@invoked_instance)
      @generator_class.invoke(:test)
      @instance = @generator_class.new('/tmp', {}, 'test', 'argument')
      
      @instance.invocations.first.should == @invoked_instance
    end
    
  end
  
  describe "with a block" do
    
    before(:each) do
      @generator_class.stub!(:manifold).and_return(@manifold)
    end
    
    it "should pass the generator class to the block and return the result of it" do    
      @generator_class.invoke(:test) do |generator|
        generator.new(destination_root, options, 'blah', 'monkey', some_method)
      end
      @instance = @generator_class.new('/tmp', {}, 'test', 'argument')
      
      @instance.should_receive(:some_method).and_return('da')
      @invoked_generator.should_receive(:new).with('/tmp', {}, 'blah', 'monkey', 'da').and_return(@invoked_instance)
      
      @instance.invocations.first.should == @invoked_instance
    end
    
    it "should ask the manifold for the generator" do
      @generator_class.should_receive(:manifold).at_least(:once).and_return(@manifold)
      @manifold.should_receive(:generator).with(:test).and_return(@invoked_generator)
      
      @generator_class.invoke(:test) do |generator|
        generator.new(destination_root, options, 'blah', 'monkey')
      end

      @instance = @generator_class.new('/tmp', {}, 'test', 'argument')      
      @instance.invocations.first.should == @invoked_instance
    end
  end
end

describe Templater::Generator, '#invocations' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.class_eval do
      def source_root
        '/tmp/source'
      end
    end
    
    @generator1 = mock('a generator for merb')
    @instance1 = mock('an instance of the generator for merb')
    @generator1.stub!(:new).and_return(@instance1)
    @generator2 = mock('a generator for rails')
    @instance2 = mock('an instance of the generator for rails')
    @generator2.stub!(:new).and_return(@instance2)
    @generator3 = mock('a generator for both')
    @instance3 = mock('an instance of the generator for both')
    @generator3.stub!(:new).and_return(@instance3)
    
    @manifold = mock('a manifold')
    @manifold.stub!(:generator).with(:merb).and_return(@generator1)
    @manifold.stub!(:generator).with(:rails).and_return(@generator2)
    @manifold.stub!(:generator).with(:both).and_return(@generator3)
    
    @generator_class.stub!(:manifold).and_return(@manifold)
  end

  it "should return all invocations" do
    @generator_class.invoke(:merb)
    @generator_class.invoke(:rails)
    
    instance = @generator_class.new('/tmp')
    
    instance.invocations[0].should == @instance1
    instance.invocations[1].should == @instance2
  end
  
  it "should not return invocations with an option that does not match." do
    @generator_class.option :framework, :default => :rails
    
    @generator_class.invoke(:merb, :framework => :merb)
    @generator_class.invoke(:rails, :framework => :rails)
    @generator_class.invoke(:both)
    
    instance = @generator_class.new('/tmp')

    instance.invocations[0].should == @instance2
    instance.invocations[1].should == @instance3
                                      
    instance.framework = :merb        
    instance.invocations[0].should == @instance1
    instance.invocations[1].should == @instance3

    instance.framework = :rails       
    instance.invocations[0].should == @instance2
    instance.invocations[1].should == @instance3

    instance.framework = nil          
    instance.invocations[0].should == @instance3
  end
  
  it "should not return invocations with blocks with an option that does not match." do
    @generator_class.send(:attr_accessor, :framework)
    
    instance1, instance2, instance3 = @instance1, @instance2, @instance3
    
    @generator_class.invoke(:merb, :framework => :merb) { instance1 }
    @generator_class.invoke(:rails, :framework => :rails) { instance2 }
    @generator_class.invoke(:both) { instance3 }
    
    instance = @generator_class.new('/tmp')

    instance.framework = :merb        
    instance.invocations[0].should == @instance1
    instance.invocations[1].should == @instance3

    instance.framework = :rails       
    instance.invocations[0].should == @instance2
    instance.invocations[1].should == @instance3

    instance.framework = nil          
    instance.invocations[0].should == @instance3
  end
end
