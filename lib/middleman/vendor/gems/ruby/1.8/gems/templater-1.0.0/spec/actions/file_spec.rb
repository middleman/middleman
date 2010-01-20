require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Actions::File do

  before do
    @generator = mock('a generator')
    @generator.stub!(:source_root).and_return(tmp('source'))
    @generator.stub!(:destination_root).and_return(tmp('destination'))
  end

  describe '.new' do
    it "should set name, source and destination" do
      file = Templater::Actions::File.new(@generator, :monkey, tmp('/path/to/source'), tmp('/path/to/destination'))
      file.name.should == :monkey
      file.source.should == tmp('/path/to/source')
      file.destination.should == tmp('/path/to/destination')
    end
  end

  describe '#relative_destination' do
    it "should get the destination relative to the generator's destination root" do
      @generator.stub!(:destination_root).and_return(tmp('/path/to'))
      file = Templater::Actions::File.new(@generator, :monkey, tmp('/path/to/source'), tmp('/path/to/destination/with/some/more/subdirs'))
      file.relative_destination.should == 'destination/with/some/more/subdirs'
    end
  end

  describe '#render' do
    it "should output the file" do  
      file = Templater::Actions::File.new(@generator, :monkey, template_path('simple_erb.rbt'), '/path/to/destination')
      file.render.should == "test<%= 1+1 %>test"
    end
  end

  describe '#exists?' do
    it "should exist if the destination file exists" do  
      file = Templater::Actions::File.new(@generator, :monkey, template_path('simple.rbt'), result_path('erb.rbs'))
      file.should be_exists
    end

    it "should not exist if the destination file does not exist" do  
      file = Templater::Actions::File.new(@generator, :monkey, template_path('simple.rbt'), result_path('some_weird_file.rbs'))
      file.should_not be_exists
    end
  end

  describe '#identical' do
    it "should not be identical if the destination file doesn't exist" do  
      file = Templater::Actions::File.new(@generator, :monkey, template_path('simple_erb.rbt'), result_path('some_weird_file.rbs'))
      file.should_not be_identical
    end

    it "should not be identical if the destination file is not identical to the source file" do
      file = Templater::Actions::File.new(@generator, :monkey, template_path('simple_erb.rbt'), result_path('simple_erb.rbs'))
      file.should be_exists
      file.should_not be_identical
    end

    it "should be identical if the destination file is identical to the source file" do
      file= Templater::Actions::File.new(@generator, :monkey, template_path('simple_erb.rbt'), result_path('file.rbs'))
      file.should be_exists
      file.should be_identical
    end
  end

  describe '#invoke!' do
    it "should copy the source file to the destination" do
      file = Templater::Actions::File.new(@generator, :monkey, template_path('simple_erb.rbt'), result_path('path/to/subdir/test2.rbs'))

      file.invoke!

      File.exists?(result_path('path/to/subdir/test2.rbs')).should be_true
      FileUtils.identical?(template_path('simple_erb.rbt'), result_path('path/to/subdir/test2.rbs')).should be_true
    end
    
    it "should trigger before and after callbacks" do
      @options = { :before => :ape, :after => :elephant }
      file = Templater::Actions::File.new(@generator, :monkey, template_path('simple_erb.rbt'), result_path('path/to/subdir/test2.rbs'), @options)

      @generator.should_receive(:ape).with(file).ordered
      @generator.should_receive(:elephant).with(file).ordered

      file.invoke!
    end
    
    after do
      FileUtils.rm_rf(result_path('path'))
    end
  end

  describe '#revoke!' do
    it "should remove the destination file" do
      file = Templater::Actions::File.new(@generator, :monkey, template_path('simple_erb.rbt'), result_path('path/to/subdir/test2.rbs'))

      file.invoke!

      File.exists?(result_path('path/to/subdir/test2.rbs')).should be_true
      FileUtils.identical?(template_path('simple_erb.rbt'), result_path('path/to/subdir/test2.rbs')).should be_true

      file.revoke!

      File.exists?(result_path('path/to/subdir/test2.rbs')).should be_false
    end

    it "should do nothing when the destination file doesn't exist" do
      file = Templater::Actions::File.new(@generator, :monkey, template_path('simple_erb.rbt'), result_path('path/to/subdir/test2.rbs'))

      lambda { file.revoke! }.should_not raise_error
    end
  end

end
