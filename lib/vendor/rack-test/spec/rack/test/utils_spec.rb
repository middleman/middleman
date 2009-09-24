require File.dirname(__FILE__) + "/../../spec_helper"

describe Rack::Test::Utils do
  include Rack::Test::Utils

  describe "requestify" do
    it "converts empty strings to =" do
      requestify("").should == "="
    end

    it "converts nil to =" do
      requestify(nil).should == "="
    end

    it "converts hashes" do
      requestify(:a => 1).should == "a=1"
    end

    it "converts hashes with multiple keys" do
      hash = { :a => 1, :b => 2 }
      ["a=1&b=2", "b=2&a=1"].should include(requestify(hash))
    end

    it "converts arrays with one element" do
      requestify(:a => [1]).should == "a[]=1"
    end

    it "converts arrays with multiple elements" do
      requestify(:a => [1, 2]).should == "a[]=1&a[]=2"
    end

    it "converts nested hashes" do
      requestify(:a => { :b => 1 }).should == "a[b]=1"
    end

    it "converts arrays nested in a hash" do
      requestify(:a => { :b => [1, 2] }).should == "a[b][]=1&a[b][]=2"
    end

    it "converts arrays of hashes" do
      requestify(:a => [{ :b => 2}, { :c => 3}]).should == "a[][b]=2&a[][c]=3"
    end
  end
end
