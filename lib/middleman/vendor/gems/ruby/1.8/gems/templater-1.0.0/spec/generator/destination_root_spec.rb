require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '#destination_root' do
  it "should be remembered" do
    @generator_class = Class.new(Templater::Generator)
    instance = @generator_class.new('/path/to/destination')
    instance.destination_root.should == '/path/to/destination'
  end
end
