require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '.template' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.stub!(:source_root).and_return(tmp('source'))
  end

  it "should add a template with source and destination" do
    @generator_class.template(:my_template, 'path/to/source.rbt', 'path/to/destination.rb')
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.template(:my_template).source.should == tmp('/source/path/to/source.rbt')
    @instance.template(:my_template).destination.should == tmp('/destination/path/to/destination.rb')
    @instance.template(:my_template).should be_an_instance_of(Templater::Actions::Template)
  end
  
  it "should add a template with absolute source and destination" do
    @generator_class.template(:my_template, tmp('/path/to/source.rbt'), tmp('/path/to/destination.rb'))
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.template(:my_template).source.should == tmp('/path/to/source.rbt')
    @instance.template(:my_template).destination.should == tmp('/path/to/destination.rb')
    @instance.template(:my_template).should be_an_instance_of(Templater::Actions::Template)
  end
  
  it "should add a template with destination and infer the source" do
    @generator_class.template(:my_template, 'path/to/destination.rb')
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.template(:my_template).source.should == tmp('/source/path/to/destination.rbt')
    @instance.template(:my_template).destination.should == tmp('/destination/path/to/destination.rb')
    @instance.template(:my_template).should be_an_instance_of(Templater::Actions::Template)
  end
  
  it "should add a template with a block" do
    @generator_class.template(:my_template) do |template|
      template.source = 'blah.rbt'
      template.destination = "gurr#{Process.pid.to_s}.rb"
    end
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.template(:my_template).source.should == tmp('/source/blah.rbt')
    @instance.template(:my_template).destination.should == tmp("/destination/gurr#{Process.pid.to_s}.rb")
    @instance.template(:my_template).should be_an_instance_of(Templater::Actions::Template)
  end
  
  it "should add a template with a complex block" do
    @generator_class.template(:my_template) do |template|
      template.source = 'blah' / 'blah.rbt'
      template.destination = 'gurr' / "gurr#{something}.rb"
    end
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.stub!(:something).and_return('anotherthing')
    
    @instance.template(:my_template).source.should == tmp('/source/blah/blah.rbt')
    @instance.template(:my_template).destination.should == tmp("/destination/gurr/gurranotherthing.rb")
    @instance.template(:my_template).should be_an_instance_of(Templater::Actions::Template)
  end
  
  it "should add a template and convert an with an instruction encoded in the destination, but not one encoded in the source" do
    @generator_class.template(:my_template, 'template/%some_method%.rbt', 'template/%another_method%.rb')
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.should_not_receive(:some_method)
    @instance.should_receive(:another_method).at_least(:once).and_return('beast')
    
    @instance.template(:my_template).source.should == tmp('/source/template/%some_method%.rbt')
    @instance.template(:my_template).destination.should == tmp("/destination/template/beast.rb")
    @instance.template(:my_template).should be_an_instance_of(Templater::Actions::Template)
  end
  
  it "should add a template and leave an encoded instruction be if it doesn't exist as a method" do
    @generator_class.template(:my_template, 'template/blah.rbt', 'template/%some_method%.rb')
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.template(:my_template).destination.should == tmp("/destination/template/%some_method%.rb")
    @instance.template(:my_template).should be_an_instance_of(Templater::Actions::Template)
  end
  
  it "should pass options on to the template" do
    @generator_class.template(:my_template, 'path/to/destination.rb', :before => :monkey, :after => :donkey)
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.template(:my_template).options[:before].should == :monkey
    @instance.template(:my_template).options[:after].should == :donkey
  end
  
end

describe Templater::Generator, '.template_list' do
  
  it "should add a series of templates given a list as heredoc" do
    @generator_class = Class.new(Templater::Generator)
    
    @generator_class.should_receive(:template).with(:app_model_rb, 'app/model.rb')
    @generator_class.should_receive(:template).with(:spec_model_rb, 'spec/model.rb')
    @generator_class.should_receive(:template).with(:donkey_poo_css, 'donkey/poo.css')
    @generator_class.should_receive(:template).with(:john_smith_file_rb, 'john/smith/file.rb')
    
    @generator_class.template_list <<-LIST
      app/model.rb
      spec/model.rb
      donkey/poo.css
      john/smith/file.rb
    LIST
  end
  
  it "should add a series of templates given a list as array" do
    @generator_class = Class.new(Templater::Generator)
    
    @generator_class.should_receive(:template).with(:app_model_rb, 'app/model.rb')
    @generator_class.should_receive(:template).with(:spec_model_rb, 'spec/model.rb')
    @generator_class.should_receive(:template).with(:donkey_poo_css, 'donkey/poo.css')
    @generator_class.should_receive(:template).with(:john_smith_file_rb, 'john/smith/file.rb')
    
    @generator_class.template_list(%w(app/model.rb spec/model.rb donkey/poo.css john/smith/file.rb))
  end
  
end

describe Templater::Generator, '#templates' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.stub!(:source_root).and_return('/tmp/source')
  end

  it "should return all templates" do
    @generator_class.template(:blah1, 'blah.rb')
    @generator_class.template(:blah2, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')
    
    instance.templates[0].name.should == :blah1
    instance.templates[1].name.should == :blah2
  end
  
  it "should not return templates with an option that does not match." do
    @generator_class.option :framework, :default => :rails
    
    @generator_class.template(:merb, 'blah.rb', :framework => :merb)
    @generator_class.template(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.template(:none, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')

    instance.templates[0].name.should == :rails
    instance.templates[1].name.should == :none

    instance.framework = :merb
    instance.templates[0].name.should == :merb
    instance.templates[1].name.should == :none

    instance.framework = :rails
    instance.templates[0].name.should == :rails
    instance.templates[1].name.should == :none
    
    instance.framework = nil
    instance.templates[0].name.should == :none
  end
end


describe Templater::Generator, '#template' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.stub!(:source_root).and_return(tmp('/tmp/source'))
  end

  it "should find a template by name" do
    @generator_class.template(:blah1, 'blah.rb')
    @generator_class.template(:blah2, 'blah2.rb')
    
    instance = @generator_class.new(tmp('tmp'))
    
    instance.template(:blah1).name.should == :blah1
    instance.template(:blah1).source.should == tmp('/tmp/source/blah.rbt')
    instance.template(:blah1).destination.should == tmp('/tmp/blah.rb')
  end
  
  it "should not return a template with an option that does not match." do
    @generator_class.send(:attr_accessor, :framework)
    
    @generator_class.template(:merb, 'blah.rb', :framework => :merb)
    @generator_class.template(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.template(:none, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')

    instance.framework = :rails
    instance.template(:rails).name.should == :rails
    instance.template(:merb).should be_nil
    instance.template(:none).name.should == :none

    instance.framework = :merb
    instance.template(:rails).should be_nil
    instance.template(:merb).name.should == :merb
    instance.template(:none).name.should == :none

    instance.framework = nil
    instance.template(:rails).should be_nil
    instance.template(:merb).should be_nil
    instance.template(:none).name.should == :none
  end
end