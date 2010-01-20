require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, ".empty_directory" do
  before do
    @generator_class = Class.new(Templater::Generator)
  end
  
  it "should add an empty_directory" do
    @generator_class.empty_directory(:my_empty_directory, 'path/to/destination.rb')
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.stub!(:source_root).and_return(tmp('source'))
    
    @instance.empty_directory(:my_empty_directory).destination.should == tmp('/destination/path/to/destination.rb')
    @instance.empty_directory(:my_empty_directory).should be_an_instance_of(Templater::Actions::EmptyDirectory)
  end
  
  it "should add a empty_directory and convert an instruction encoded in the destination" do
    @generator_class.empty_directory(:my_empty_directory, 'template/%another_method%.rb')
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.should_receive(:another_method).at_least(:once).and_return('beast')
    
    @instance.empty_directory(:my_empty_directory).destination.should == tmp("/destination/template/beast.rb")
    @instance.empty_directory(:my_empty_directory).should be_an_instance_of(Templater::Actions::EmptyDirectory)
  end
  
  it "should add an empty directory with a block" do
    @generator_class.empty_directory(:my_empty_directory) do |action|
      action.destination = "gurr#{Process.pid.to_s}.rb"
    end
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.empty_directory(:my_empty_directory).destination.should == tmp("/destination/gurr#{Process.pid.to_s}.rb")
    @instance.empty_directory(:my_empty_directory).should be_an_instance_of(Templater::Actions::EmptyDirectory)
  end
  
  it "should add an empty directory with a complex block" do
    @generator_class.empty_directory(:my_empty_directory) do |action|
      action.destination = 'gurr' / "gurr#{something}.rb"
    end
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.stub!(:something).and_return('anotherthing')
    
    @instance.empty_directory(:my_empty_directory).destination.should == tmp("/destination/gurr/gurranotherthing.rb")
    @instance.empty_directory(:my_empty_directory).should be_an_instance_of(Templater::Actions::EmptyDirectory)
  end
  
  it "should add a empty_directory and leave an encoded instruction be if it doesn't exist as a method" do
    @generator_class.empty_directory(:my_empty_directory, 'template/%some_method%.rb')
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.empty_directory(:my_empty_directory).destination.should == tmp("/destination/template/%some_method%.rb")
    @instance.empty_directory(:my_empty_directory).should be_an_instance_of(Templater::Actions::EmptyDirectory)
  end
  
  it "should pass options on to the empty_directory" do
    @generator_class.empty_directory(:my_empty_directory, 'path/to/destination.rb', :before => :monkey, :after => :donkey)
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.empty_directory(:my_empty_directory).options[:before].should == :monkey
    @instance.empty_directory(:my_empty_directory).options[:after].should == :donkey
  end
end

describe Templater::Generator, '#empty_directories' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should return all empty directories" do
    @generator_class.empty_directory(:blah1, 'blah.rb')
    @generator_class.empty_directory(:blah2, 'blah2.rb')
    
    instance = @generator_class.new(tmp('tmp'))
    
    instance.empty_directories[0].name.should == :blah1
    instance.empty_directories[1].name.should == :blah2
  end
  
  it "should not return empty directories with an option that does not match." do
    @generator_class.option :framework, :default => :rails
    
    @generator_class.empty_directory(:merb, 'blah.rb', :framework => :merb)
    @generator_class.empty_directory(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.empty_directory(:none, 'blah2.rb')
    
    instance = @generator_class.new(tmp('tmp'))

    instance.empty_directories[0].name.should == :rails
    instance.empty_directories[1].name.should == :none

    instance.framework = :merb
    instance.empty_directories[0].name.should == :merb
    instance.empty_directories[1].name.should == :none

    instance.framework = :rails
    instance.empty_directories[0].name.should == :rails
    instance.empty_directories[1].name.should == :none
    
    instance.framework = nil
    instance.empty_directories[0].name.should == :none
  end
end

describe Templater::Generator, '#empty_directory' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should find a empty_directory by name" do
    @generator_class.empty_directory(:blah1, 'blah.rb')
    @generator_class.empty_directory(:blah2, 'blah2.rb')
    
    instance = @generator_class.new(tmp('tmp'))
    
    instance.empty_directory(:blah1).name.should == :blah1
    instance.empty_directory(:blah1).destination.should == tmp('/tmp/blah.rb')
  end
  
  it "should not return a empty_directory with an option that does not match." do
    @generator_class.send(:attr_accessor, :framework)
    
    @generator_class.empty_directory(:merb, 'blah.rb', :framework => :merb)
    @generator_class.empty_directory(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.empty_directory(:none, 'blah2.rb')
    
    instance = @generator_class.new(tmp('tmp'))

    instance.framework = :rails
    instance.empty_directory(:rails).name.should == :rails
    instance.empty_directory(:merb).should be_nil
    instance.empty_directory(:none).name.should == :none

    instance.framework = :merb
    instance.empty_directory(:rails).should be_nil
    instance.empty_directory(:merb).name.should == :merb
    instance.empty_directory(:none).name.should == :none

    instance.framework = nil
    instance.empty_directory(:rails).should be_nil
    instance.empty_directory(:merb).should be_nil
    instance.empty_directory(:none).name.should == :none
  end
end