require File.join(File.dirname(__FILE__), "spec_helper")

base = ::Middleman::Base
base.set :root, File.join(File.dirname(__FILE__), "fixtures", "sample")

describe "Cache Buster Feature" do
  it "should not append query string if off" do
    base.disable :cache_buster
    base.init!(true, true)
    base.asset_url("stylesheets/static.css").should_not include("?")
  end
  
  it "should append query string if on" do
    base.enable :cache_buster
    base.init!(true, true)
    base.asset_url("stylesheets/static.css").should include("?")
  end
end