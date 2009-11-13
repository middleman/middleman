require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Actions::Directory do
  before(:each) do
    
  end

  before do
    @generator = mock('a generator')
    @generator.stub!(:source_root).and_return('/tmp/source')
    @generator.stub!(:destination_root).and_return('/tmp/destination')
  end

  describe '#render' do
    it "returns empty string" do  
      file = Templater::Actions::Directory.new(@generator, :monkey, template_path('simple_erb.rbt'), '/path/to/destination')
      file.render.should == ""
    end
  end
  
end
