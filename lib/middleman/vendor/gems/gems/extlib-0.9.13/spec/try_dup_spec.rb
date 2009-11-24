require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe "try_dup" do
  it "returns a duplicate version on regular objects" do
    obj = Object.new
    oth = obj.try_dup
    obj.should_not === oth
  end

  it "returns self on Numerics" do
    obj = 12
    oth = obj.try_dup
    obj.should === oth
  end

  it "returns self on Symbols" do
    obj = :test
    oth = obj.try_dup
    obj.should === oth
  end

  it "returns self on true" do
    obj = true
    oth = obj.try_dup
    obj.should === oth
  end

  it "returns self on false" do
    obj = false
    oth = obj.try_dup
    obj.should === oth
  end

  it "returns self on nil" do
    obj = nil
    oth = obj.try_dup
    obj.should === oth
  end

  it "returns self on modules" do
    obj = Extlib
    oth = obj.try_dup
    obj.object_id.should == oth.object_id
  end
end
