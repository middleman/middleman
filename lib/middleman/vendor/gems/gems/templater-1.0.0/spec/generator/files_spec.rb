require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '.file' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.stub!(:source_root).and_return(tmp('source'))
  end

  it "should add a file with source and destination" do
    @generator_class.file(:my_template, 'path/to/source.rbt', 'path/to/destination.rb')
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.file(:my_template).source.should == tmp('/source/path/to/source.rbt')
    @instance.file(:my_template).destination.should == tmp('/destination/path/to/destination.rb')
    @instance.file(:my_template).should be_an_instance_of(Templater::Actions::File)
  end
  
  it "should add a file with source and infer destination " do
    @generator_class.file(:my_template, 'path/to/file.rb')
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.file(:my_template).source.should == tmp('/source/path/to/file.rb')
    @instance.file(:my_template).destination.should == tmp('/destination/path/to/file.rb')
    @instance.file(:my_template).should be_an_instance_of(Templater::Actions::File)
  end
  
  it "should add a file with a block" do
    @generator_class.file(:my_file) do |file|
      file.source = 'blah.rbt'
      file.destination = "gurr#{Process.pid.to_s}.rb"
    end
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.file(:my_file).source.should == tmp('/source/blah.rbt')
    @instance.file(:my_file).destination.should == tmp("/destination/gurr#{Process.pid.to_s}.rb")
    @instance.file(:my_file).should be_an_instance_of(Templater::Actions::File)
  end
  
  it "should add a file with a complex block" do
    @generator_class.file(:my_file) do |file|
      file.source = 'blah' / 'blah.rbt'
      file.destination = 'gurr' / "gurr#{something}.rb"
    end
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.stub!(:something).and_return('anotherthing')
    
    @instance.file(:my_file).source.should == tmp('/source/blah/blah.rbt')
    @instance.file(:my_file).destination.should == tmp("/destination/gurr/gurranotherthing.rb")
    @instance.file(:my_file).should be_an_instance_of(Templater::Actions::File)
  end
  
  it "should add a file and convert an instruction encoded in the destination, but not one encoded in the source" do
    @generator_class.file(:my_template, 'template/%some_method%.rbt', 'template/%another_method%.rb')
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.should_not_receive(:some_method)
    @instance.should_receive(:another_method).at_least(:once).and_return('beast')
    
    @instance.file(:my_template).source.should == tmp('/source/template/%some_method%.rbt')
    @instance.file(:my_template).destination.should == tmp("/destination/template/beast.rb")
    @instance.file(:my_template).should be_an_instance_of(Templater::Actions::File)
  end
  
  it "should add a file and leave an encoded instruction be if it doesn't exist as a method" do
    @generator_class.file(:my_template, 'template/blah.rbt', 'template/%some_method%.rb')
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.file(:my_template).destination.should == tmp("/destination/template/%some_method%.rb")
    @instance.file(:my_template).should be_an_instance_of(Templater::Actions::File)
  end
  
  it "should pass options on to the file" do
    @generator_class.file(:my_template, 'path/to/destination.rb', :before => :monkey, :after => :donkey)
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.file(:my_template).options[:before].should == :monkey
    @instance.file(:my_template).options[:after].should == :donkey
  end
end

describe Templater::Generator, '.file_list' do
  
  it "should add a series of files given a list as heredoc" do
    @generator_class = Class.new(Templater::Generator)
    
    @generator_class.should_receive(:file).with(:app_model_rb, 'app/model.rb')
    @generator_class.should_receive(:file).with(:spec_model_rb, 'spec/model.rb')
    @generator_class.should_receive(:file).with(:donkey_poo_css, 'donkey/poo.css')
    @generator_class.should_receive(:file).with(:john_smith_file_rb, 'john/smith/file.rb')
    
    @generator_class.file_list <<-LIST
      app/model.rb
      spec/model.rb
      donkey/poo.css
      john/smith/file.rb
    LIST
  end
  
  it "should add a series of files given a list as array" do
    @generator_class = Class.new(Templater::Generator)
    
    @generator_class.should_receive(:file).with(:app_model_rb, 'app/model.rb')
    @generator_class.should_receive(:file).with(:spec_model_rb, 'spec/model.rb')
    @generator_class.should_receive(:file).with(:donkey_poo_css, 'donkey/poo.css')
    @generator_class.should_receive(:file).with(:john_smith_file_rb, 'john/smith/file.rb')
    
    @generator_class.file_list(%w(app/model.rb spec/model.rb donkey/poo.css john/smith/file.rb))
  end
  
end

describe Templater::Generator, '#files' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.stub!(:source_root).and_return('/tmp/source')
  end

  it "should return all files" do
    @generator_class.file(:blah1, 'blah.rb')
    @generator_class.file(:blah2, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')
    
    instance.files[0].name.should == :blah1
    instance.files[1].name.should == :blah2
  end
  
  it "should not return files with an option that does not match." do
    @generator_class.option :framework, :default => :rails
    
    @generator_class.file(:merb, 'blah.rb', :framework => :merb)
    @generator_class.file(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.file(:none, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')

    instance.files[0].name.should == :rails
    instance.files[1].name.should == :none

    instance.framework = :merb
    instance.files[0].name.should == :merb
    instance.files[1].name.should == :none

    instance.framework = :rails
    instance.files[0].name.should == :rails
    instance.files[1].name.should == :none
    
    instance.framework = nil
    instance.files[0].name.should == :none
  end
end


describe Templater::Generator, '#file' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.stub!(:source_root).and_return(tmp('source'))
  end

  it "should find a file by name" do
    @generator_class.file(:blah1, 'blah.rb')
    @generator_class.file(:blah2, 'blah2.rb')
    
    instance = @generator_class.new(tmp('tmp'))
    
    instance.file(:blah1).name.should == :blah1
    instance.file(:blah1).source.should == tmp('/source/blah.rb')
    instance.file(:blah1).destination.should == tmp('/tmp/blah.rb')
  end
  
  it "should not return a file with an option that does not match." do
    @generator_class.send(:attr_accessor, :framework)
    
    @generator_class.file(:merb, 'blah.rb', :framework => :merb)
    @generator_class.file(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.file(:none, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')

    instance.framework = :rails
    instance.file(:rails).name.should == :rails
    instance.file(:merb).should be_nil
    instance.file(:none).name.should == :none

    instance.framework = :merb
    instance.file(:rails).should be_nil
    instance.file(:merb).name.should == :merb
    instance.file(:none).name.should == :none

    instance.framework = nil
    instance.file(:rails).should be_nil
    instance.file(:merb).should be_nil
    instance.file(:none).name.should == :none
  end
end
