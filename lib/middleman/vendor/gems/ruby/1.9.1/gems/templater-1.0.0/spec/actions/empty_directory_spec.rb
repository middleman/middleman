require File.dirname(__FILE__) + '/../spec_helper'
 
describe Templater::Actions::EmptyDirectory do

  before do
    @generator = mock('a generator')
    @generator.stub!(:source_root).and_return('/tmp/source')
    @generator.stub!(:destination_root).and_return('/tmp/destination')
  end

  describe '.new' do
    it "sets name and destination" do
      Templater::Actions::EmptyDirectory.new(@generator, :monkey, '/path/to/destination').
      name.should == :monkey
    end

    it 'sets destination' do
      Templater::Actions::EmptyDirectory.new(@generator, :monkey, tmp('/path/to/destination')).
      destination.should == tmp('/path/to/destination')
    end
  end

  describe '#relative_destination' do
    it "returns the destination relative to the generator's destination root" do
      @generator.stub!(:destination_root).and_return(tmp('/path/to'))
      file = Templater::Actions::EmptyDirectory.new(@generator, :monkey, tmp('/path/to/destination/with/some/more/subdirs'))
      file.relative_destination.should == 'destination/with/some/more/subdirs'
    end
  end

  describe '#render' do
    it 'should return an empty string' do
      file = Templater::Actions::EmptyDirectory.new(@generator, :monkey, '/path/to/destination')
      file.render.should == ''
    end 
  end

  describe '#exists?' do

    it "should exist if the destination file exists" do  
      file = Templater::Actions::EmptyDirectory.new(@generator, :monkey, result_path('erb.rbs'))
      file.should be_exists
    end

    it "should not exist if the destination file does not exist" do  
      file = Templater::Actions::EmptyDirectory.new(@generator, :monkey, result_path('some_weird_file.rbs'))
      file.should_not be_exists
    end
  end

  describe '#identical' do
    it "should not be identical if the destination file doesn't exist" do  
      file = Templater::Actions::EmptyDirectory.new(@generator, :monkey, result_path('some_weird/path/that_does/not_exist'))
      file.should_not be_identical
    end

    it "should not be identical if the destination file is not identical to the source file" do
      file = Templater::Actions::EmptyDirectory.new(@generator, :monkey, result_path('simple_erb.rbs'))
      file.should be_exists
      file.should be_identical
    end

    it "should be identical if the destination file is identical to the source file" do
      file= Templater::Actions::EmptyDirectory.new(@generator, :monkey, result_path('file.rbs'))
      file.should be_exists
      file.should be_identical
    end
  end

  describe '#invoke!' do
    it "should copy the source file to the destination" do
      file = Templater::Actions::EmptyDirectory.new(@generator, :monkey, result_path('path/to/subdir/test2.rbs'))

      file.invoke!

      File.exists?(result_path('path/to/subdir/test2.rbs')).should be_true
    end
    
    it "should trigger before and after callbacks" do
      @options = { :before => :ape, :after => :elephant }
      file = Templater::Actions::EmptyDirectory.new(@generator, :monkey, result_path('path/to/subdir/test2.rbs'), @options)

      @generator.should_receive(:ape).with(file).ordered
      @generator.should_receive(:elephant).with(file).ordered

      file.invoke!

      File.exists?(result_path('path/to/subdir/test2.rbs')).should be_true
    end
    
    after do
      FileUtils.rm_rf(result_path('path'))
    end
  end

  describe '#revoke!' do
    it "removes the destination directory" do
      file = Templater::Actions::EmptyDirectory.new(@generator, :monkey, result_path('path/to/empty/subdir/'))

      file.invoke!
      File.exists?(result_path('path/to/empty/subdir/')).should be_true

      file.revoke!
      File.exists?(result_path('path/to/empty/subdir/')).should be_false
    end
  end

end
