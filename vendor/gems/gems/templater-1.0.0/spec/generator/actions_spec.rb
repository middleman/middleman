require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '#actions' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.stub!(:source_root).and_return('/tmp/source')
  end

  it "should return all actions" do    
    @generator_class.template :one, 'template1.rb'
    @generator_class.template :two, 'template2.rb'
    @generator_class.file :three, 'file1.rb'
    @generator_class.empty_directory :four, 'file2.rb'
    
    instance = @generator_class.new('/tmp')
    
    instance.actions.should have_names(:one, :two, :three, :four)
  end
  
  it "should return only a certain type of action" do
    @generator_class.template :one, 'template1.rb'
    @generator_class.template :two, 'template2.rb'
    @generator_class.file :three, 'file1.rb'
    @generator_class.empty_directory :four, 'file2.rb'
    
    instance = @generator_class.new('/tmp')
    
    instance.actions(:templates).should have_names(:one, :two)
  end
end

describe Templater::Generator, '#all_actions' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.stub!(:source_root).and_return('/tmp/source')
    
    @generator_class2 = Class.new(Templater::Generator)
    @generator_class2.stub!(:source_root).and_return('/tmp/source')
    
    @generator_class3 = Class.new(Templater::Generator)
    @generator_class3.stub!(:source_root).and_return('/tmp/source')    
    
    @manifold = Object.new
    @manifold.extend Templater::Manifold
    @manifold.add(:one, @generator_class)
    @manifold.add(:two, @generator_class2)
    @manifold.add(:three, @generator_class3)
  end

  it "should return all actions" do    
    @generator_class.template :one, 'template1.rb'
    @generator_class.template :two, 'template2.rb'
    @generator_class.file :three, 'file1.rb'
    @generator_class.empty_directory :four, 'file2.rb'
    instance = @generator_class.new('/tmp')
    
    instance.all_actions.should have_names(:one, :two, :three, :four)
  end
  
  it "should return only a certain type of action" do
    @generator_class.template :one, 'template1.rb'
    @generator_class.template :two, 'template2.rb'
    @generator_class.file :three, 'file1.rb'
    @generator_class.empty_directory :four, 'file2.rb'
    
    instance = @generator_class.new('/tmp')
    
    instance.all_actions(:templates).should have_names(:one, :two)
  end
  
  it "should return all actions recursively for all invocations" do
    @generator_class.invoke :two
    @generator_class2.invoke :three
    
    @generator_class.template :one, 'template1.rb'
    @generator_class.file :two, 'file1.rb'
    @generator_class.empty_directory :three, 'file2.rb'

    @generator_class2.file :four, 'file2.rb'
    @generator_class2.template :five, 'file2.rb'
    
    @generator_class3.template :six, 'fds.rb'
    @generator_class3.empty_directory :seven, 'dfsd.rb'

    instance = @generator_class.new('/tmp')
    
    instance.all_actions.should have_names(:one, :two, :three, :four, :five, :six, :seven)
  end
  
  it "should return only a certain type of actions recursively for all invocations" do
    @generator_class.invoke :two
    @generator_class2.invoke :three
    
    @generator_class.template :one, 'template1.rb'
    @generator_class.file :two, 'file1.rb'
    @generator_class.empty_directory :three, 'file2.rb'

    @generator_class2.file :four, 'file2.rb'
    @generator_class2.template :five, 'file2.rb'
    
    @generator_class3.template :six, 'fds.rb'
    @generator_class3.empty_directory :seven, 'dfsd.rb'

    instance = @generator_class.new('/tmp')
    
    instance.all_actions(:templates).should have_names(:one, :five, :six)
  end
  
end
