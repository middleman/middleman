require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '.glob!' do
  
  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.stub!(:source_root).and_return(template_path('glob'))
  end
  
  it "should add templates and files in the source_root based on if their extensions are in the template_extensions array" do
    @generator_class.glob!()
    
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.template(:arg_js).source.should == template_path('glob/arg.js')
    @instance.template(:arg_js).destination.should == tmp("/destination/arg.js")

    @instance.template(:test_rb).source.should == template_path('glob/test.rb')
    @instance.template(:test_rb).destination.should == tmp("/destination/test.rb")
    
    @instance.file(:subfolder_jessica_alba_jpg).source.should == template_path('glob/subfolder/jessica_alba.jpg')
    @instance.file(:subfolder_jessica_alba_jpg).destination.should == tmp('/destination/subfolder/jessica_alba.jpg')
  end
  
  it "should add templates and files with a different template_extensions array" do
    @generator_class.glob!(nil, %w(jpg))
    
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.file(:arg_js).source.should == template_path('glob/arg.js')
    @instance.file(:arg_js).destination.should == tmp("/destination/arg.js")

    @instance.file(:test_rb).source.should == template_path('glob/test.rb')
    @instance.file(:test_rb).destination.should == tmp("/destination/test.rb")
    
    @instance.template(:subfolder_jessica_alba_jpg).source.should == template_path('glob/subfolder/jessica_alba.jpg')
    @instance.template(:subfolder_jessica_alba_jpg).destination.should == tmp('/destination/subfolder/jessica_alba.jpg')
  end
  
  it "should add README and other stuff without an extension as templates if in the template_extensions array" do
    @generator_class.glob!(nil, %w(README))
    
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.template(:readme).source.should == template_path('glob/README')
    @instance.template(:readme).destination.should == tmp("/destination/README")
  end
  
  it "should glob in a subdirectory" do
    @generator_class.stub!(:source_root).and_return(template_path(""))
    @generator_class.glob!('glob', %w(jpg))
    
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.file(:glob_arg_js).source.should == template_path('glob/arg.js')
    @instance.file(:glob_arg_js).destination.should == tmp("/destination/glob/arg.js")

    @instance.file(:glob_test_rb).source.should == template_path('glob/test.rb')
    @instance.file(:glob_test_rb).destination.should == tmp("/destination/glob/test.rb")
    
    @instance.template(:glob_subfolder_jessica_alba_jpg).source.should == template_path('glob/subfolder/jessica_alba.jpg')
    @instance.template(:glob_subfolder_jessica_alba_jpg).destination.should == tmp('/destination/glob/subfolder/jessica_alba.jpg')
  end
  
  it "should add only the given templates and files" do
    @generator_class.glob!()
    
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.templates.map { |t| t.name.to_s }.sort.should == [
      :arg_js,
      :hellothar_html_feh_,
      :readme,
      :subfolder_monkey_rb,
      :test_rb,
    ].map { |i| i.to_s }.sort
    @instance.files.map { |f| f.name.to_s }.sort.should == [
      :hellothar_feh_,
      :subfolder_jessica_alba_jpg
    ].map { |i| i.to_s }.sort
  end
  
  it "should ignore ending '.%..%' and look at the extension preceding it" do
    @generator_class.glob!
    
    @instance = @generator_class.new(tmp('destination'))
    
    @instance.template(:hellothar_html_feh_).source.should == template_path("glob/hellothar.html.%feh%")
    @instance.template(:hellothar_html_feh_).destination.should == tmp("/destination/hellothar.html.%feh%")
    
    @instance.file(:hellothar_feh_).source.should == template_path("glob/hellothar.%feh%")
    @instance.file(:hellothar_feh_).destination.should == tmp("/destination/hellothar.%feh%")
  end
end
