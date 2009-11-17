require 'spec_helper'

module Bug7611
  class Foo
  end

  class Bar < Foo
  end

  describe "A Partial Mock" do
    it "should respect subclasses" do
      Foo.stub!(:new).and_return(Object.new)
    end

    it "should" do
      Bar.new.class.should == Bar
    end 
  end
end
