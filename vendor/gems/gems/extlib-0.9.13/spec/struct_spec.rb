require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe Struct do

  it "should have attributes" do

    s = Struct.new(:name).new('bob')
    s.attributes.should == { :name => 'bob' }

  end

end
