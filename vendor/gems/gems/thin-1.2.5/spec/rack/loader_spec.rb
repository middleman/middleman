require File.dirname(__FILE__) + '/../spec_helper'

describe Rack::Adapter do
  before do
    @rails_path = File.dirname(__FILE__) + '/../rails_app'
  end
  
  it "should guess rails app from dir" do
    Rack::Adapter.guess(@rails_path).should == :rails
  end
  
  it "should return nil when can't guess from dir" do
    proc { Rack::Adapter.guess('.') }.should raise_error(Rack::AdapterNotFound)
  end
  
  it "should load Rails adapter" do
    Rack::Adapter::Rails.should_receive(:new)
    Rack::Adapter.for(:rails, :chdir => @rails_path)
  end
  
  it "should load File adapter" do
    Rack::File.should_receive(:new)
    Rack::Adapter.for(:file)
  end
  
  it "should raise error when adapter can't be found" do
    proc { Rack::Adapter.for(:fart, {}) }.should raise_error(Rack::AdapterNotFound)
  end
end