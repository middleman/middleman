require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '.argument' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end
  
  it "should create accessors" do
    @generator_class.argument(0, :monkey)
    
    instance = @generator_class.new('/tmp')
    instance.monkey = 'a test'
    instance.monkey.should == 'a test'
  end
  
  it "should pass an initial value to the argument" do
    @generator_class.argument(0, :monkey)
    
    instance = @generator_class.new('/tmp', {}, 'i am a monkey')
    instance.monkey.should == 'i am a monkey'
  end
  
  it "should create multiple accessors" do
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama)
    @generator_class.argument(2, :herd)
    
    instance = @generator_class.new('/tmp')
    instance.monkey = 'a monkey'
    instance.monkey.should == 'a monkey'
    instance.llama = 'a llama'
    instance.llama.should == 'a llama'
    instance.herd = 'a herd'
    instance.herd.should == 'a herd'
  end
  
  it "should pass an initial value to multiple accessors" do
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama)
    @generator_class.argument(2, :herd)
    
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'a llama', 'a herd')
    instance.monkey.should == 'a monkey'
    instance.llama.should == 'a llama'
    instance.herd.should == 'a herd'
  end
  
  it "should set a default value for an argument" do
    @generator_class.argument(0, :monkey, :default => 'a revision')
    
    instance = @generator_class.new('/tmp')
    instance.monkey.should == 'a revision'
  end
  
  it "should allow some syntactic sugar declaration" do
    @generator_class.first_argument(:monkey)
    @generator_class.second_argument(:llama)
    @generator_class.third_argument(:herd)
    @generator_class.fourth_argument(:elephant)
    
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'a llama', 'a herd', 'an elephant')
    instance.monkey.should == 'a monkey'
    instance.llama.should == 'a llama'
    instance.herd.should == 'a herd'
    instance.elephant.should == 'an elephant'
  end
  
  it "should whine when there are too many arguments" do
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama)
    
    lambda { @generator_class.new('/tmp', {}, 'a monkey', 'a llama', 'a herd') }.should raise_error(Templater::TooManyArgumentsError)
  end
  
  it "should assign arguments if an argument is required and that requirement is fullfilled" do
    @generator_class.argument(0, :monkey, :required => true)
    @generator_class.argument(1, :elephant, :required => true)
    @generator_class.argument(2, :llama)
    
    instance = @generator_class.new('/tmp', {}, 'enough', 'arguments')
    instance.monkey.should == "enough"
    instance.elephant.should == "arguments"
    instance.llama.should be_nil
  end
  
  it "should raise an error when a required argument is not passed" do
    @generator_class.argument(0, :monkey, :required => true)
    @generator_class.argument(1, :elephant, :required => true)
    @generator_class.argument(2, :llama)
    
    lambda { @generator_class.new('/tmp', {}, 'too few arguments') }.should raise_error(Templater::TooFewArgumentsError)    
  end
  
  it "should raise an error if nil is assigned to a require argument" do
    @generator_class.argument(0, :monkey, :required => true)
    
    instance = @generator_class.new('/tmp', {}, 'test')
    
    lambda { instance.monkey = nil }.should raise_error(Templater::TooFewArgumentsError)    
  end
  
  it "should assign an argument when a block appended to an argument does not throw :invalid" do
    @generator_class.argument(0, :monkey) do |argument|
      1 + 1
    end
    @generator_class.argument(1, :elephant) do
      false
    end
    @generator_class.argument(2, :llama)
    
    instance = @generator_class.new('/tmp', {}, 'blah', 'urgh')
    instance.monkey.should == 'blah'
    instance.elephant.should == 'urgh'
    
    instance.monkey = :harr
    instance.monkey.should == :harr
  end
  
  it "should raise an error with the throw message, when a block is appended to an argument and throws :invalid" do
    @generator_class.argument(0, :monkey) do |argument|
      if argument != 'monkey'
        throw :invalid, 'this is not a valid monkey, bad monkey!'
      end
    end
    
    lambda { @generator_class.new('/tmp', {}, 'blah') }.should raise_error(Templater::ArgumentError, 'this is not a valid monkey, bad monkey!')
    
    instance = @generator_class.new('/tmp')
    
    lambda { instance.monkey = :anything }.should raise_error(Templater::ArgumentError, 'this is not a valid monkey, bad monkey!')
    
    lambda { instance.monkey = 'monkey' }.should_not raise_error
  end

end

describe Templater::Generator, '.argument as array' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama, :as => :array)
  end
  
  it "should allow assignment of arrays" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', %w(an array))
    
    instance.monkey.should == 'a monkey'
    instance.llama[0].should == 'an'
    instance.llama[1].should == 'array'
    
    instance.llama = %w(another donkey)
    instance.llama[0].should == 'another'
    instance.llama[1].should == 'donkey'
  end
  
  it "should convert a single argument to an array" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'test')
    instance.llama[0].should == 'test'
  end
  
  it "should split the remaining arguments by comma and convert them to an array" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'test,silver,river')
    instance.llama[0].should == 'test'
    instance.llama[1].should == 'silver'
    instance.llama[2].should == 'river'
  end
  
  it "should raise error if the argument is not an array" do
    instance = @generator_class.new('/tmp')
    lambda { instance.llama = :not_an_array }.should raise_error(Templater::MalformattedArgumentError)
  end

end

describe Templater::Generator, '.argument as hash' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama, :as => :hash)
  end
  
  it "should allow assignment of hashes" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', { :hash => 'blah' })
    
    instance.monkey.should == 'a monkey'
    instance.llama[:hash].should == 'blah'
    
    instance.llama = { :me_s_a => :hash }
    instance.llama[:me_s_a].should == :hash
  end
  
  it "should convert a key/value pair to a hash" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'test:unit')
    instance.llama['test'].should == 'unit'
  end
  
  it "should split by comma and convert them to a hash if they are key/value pairs" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'test:unit,john:silver,river:road')
    instance.llama['test'].should == 'unit'
    instance.llama['john'].should == 'silver'
    instance.llama['river'].should == 'road'
  end
  
  it "should strip key/value pairs" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'test:unit, john:silver, river:road,   silver:bullet')
    instance.llama['test'].should == 'unit'
    instance.llama['john'].should == 'silver'
    instance.llama['river'].should == 'road'
    instance.llama['silver'].should == 'bullet'
  end

  it "should raise an error if one of the remaining arguments is not a key/value pair" do
    lambda { @generator_class.new('/tmp', {}, 'a monkey', 'a:llama,duck:llama,not_a_pair,pair:blah') }.should raise_error(Templater::MalformattedArgumentError)
  end
  
  it "should raise error if the argument is neither a hash nor a key/value pair" do
    lambda { @generator_class.new('/tmp', {}, 'a monkey', 23) }.should raise_error(Templater::MalformattedArgumentError)
    instance = @generator_class.new('/tmp')
    lambda { instance.llama = :not_a_hash }.should raise_error(Templater::MalformattedArgumentError)
  end

end
