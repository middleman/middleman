require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Actions::Template do

  before do
    @generator = mock('a generator')
    @generator.stub!(:source_root).and_return(tmp('source'))
    @generator.stub!(:destination_root).and_return(tmp('destination'))
  end

  describe '.new' do
    it "should set name, source and destination" do
      template = Templater::Actions::Template.new(@generator, :monkey, tmp('/path/to/source'), tmp('/path/to/destination'))
      template.name.should == :monkey
      template.source.should == tmp('/path/to/source')
      template.destination.should == tmp('/path/to/destination')
    end
  end

  describe '#relative_destination' do
    it "should get the destination relative to the generator's destination root" do
      @generator.stub!(:destination_root).and_return(tmp('/path/to'))
      template = Templater::Actions::Template.new(@generator, :monkey, tmp('/path/to/source'), tmp('/path/to/destination/with/some/more/subdirs'))
      template.relative_destination.should == 'destination/with/some/more/subdirs'
    end
  end

  describe '#render' do
    it "should render a simple template" do  
      template = Templater::Actions::Template.new(@generator, :monkey, template_path('simple.rbt'), '/path/to/destination')
      template.render.should == "Hello World"
    end

    it "should render some basic erb" do  
      template = Templater::Actions::Template.new(@generator, :monkey, template_path('simple_erb.rbt'), '/path/to/destination')
      template.render.should == "test2test"
    end

    it "should render some erb and convert erb literals" do  
      template = Templater::Actions::Template.new(@generator, :monkey, template_path('literals_erb.rbt'), '/path/to/destination')
      template.render.should == "test2test<%= 1+1 %>blah"
    end

    it "should render some erb fetching stuff from the context" do
      @generator.should_receive(:funkydoodle).and_return('_doodle_')
      template = Templater::Actions::Template.new(@generator, :monkey, template_path('erb.rbt'), '/path/to/destination')
      template.render.should == "test_doodle_blah"
    end
  end

  describe '#exists?' do
    it "should exist if the destination file exists" do  
      template = Templater::Actions::Template.new(@generator, :monkey, template_path('simple.rbt'), result_path('erb.rbs'))
      template.should be_exists
    end

    it "should not exist if the destination file does not exist" do  
      template = Templater::Actions::Template.new(@generator, :monkey, template_path('simple.rbt'), result_path('some_weird_file.rbs'))
      template.should_not be_exists
    end
  end

  describe '#identical' do
    before do
      @context = class << self; self end
    end

    it "should not be identical if the destination file doesn't exist" do  
      template = Templater::Actions::Template.new(@generator, :monkey, template_path('simple_erb.rbt'), result_path('some_weird_file.rbs'))
      template.should_not be_identical
    end

    it "should not be identical if the rendered content does not match the content of the file" do  
      template = Templater::Actions::Template.new(@generator, :monkey, template_path('simple_erb.rbt'), result_path('random.rbs'))
      template.should be_exists
      template.should_not be_identical
    end

    it "should be identical if the rendered content matches the content of the file" do  
      template = Templater::Actions::Template.new(@generator, :monkey, template_path('simple_erb.rbt'), result_path('simple_erb.rbs'))
      template.should be_exists
      template.should be_identical
    end
  end

  describe '#invoke!' do
    it "should render the template and copy it to the destination" do  
      template = Templater::Actions::Template.new(@generator, :monkey, template_path('simple_erb.rbt'), result_path('test.rbs'))

      template.invoke!

      File.exists?(result_path('test.rbs')).should be_true
      File.read(result_path('test.rbs')).should == "test2test"
    end

    it "should render the template and copy it to the destination, creating any required subdirectories" do  
      template = Templater::Actions::Template.new(@generator, :monkey, template_path('simple_erb.rbt'), result_path('path/to/subdir/test.rbs'))

      template.invoke!

      File.exists?(result_path('path/to/subdir/test.rbs')).should be_true
      File.read(result_path('path/to/subdir/test.rbs')).should == "test2test"
    end
    
    it "should trigger before and after callbacks" do
      @options = { :before => :ape, :after => :elephant }
      template = Templater::Actions::Template.new(@generator, :monkey, template_path('simple_erb.rbt'), result_path('path/to/subdir/test.rbs'), @options)

      @generator.should_receive(:ape).with(template).ordered
      @generator.should_receive(:elephant).with(template).ordered

      template.invoke!
    end
    
    after do
      FileUtils.rm_rf(result_path('path'))
    end
  end

  describe '#revoke!' do
    it "should remove the destination file" do
      template = Templater::Actions::Template.new(@generator, :monkey, template_path('simple_erb.rbt'), result_path('test.rbs'))

      template.invoke!

      File.exists?(result_path('test.rbs')).should be_true
      File.read(result_path('test.rbs')).should == "test2test"

      template.revoke!

      File.exists?(result_path('test.rbs')).should be_false
    end

    it "should do nothing when the destination file doesn't exist" do
      template = Templater::Actions::Template.new(@generator, :monkey, template_path('simple_erb.rbt'), result_path('test.rbs'))

      lambda { template.revoke! }.should_not raise_error
    end
  end

end
