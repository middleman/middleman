require File.join(File.dirname(__FILE__), "spec_helper")

describe "Cache Buster Feature in CSS" do
  before :each do
    @base = ::Middleman::Base
    @base.set :root, File.join(File.dirname(__FILE__), "fixtures", "sample")
    @base.enable :cache_buster
  end
  
  it "should append query string in CSS if on" do
    browser = Rack::Test::Session.new(Rack::MockSession.new(@base.new))
    browser.get("/stylesheets/relative_assets.css")
    browser.last_response.body.should include("?")
  end

  it "should append query string in HTML if on" do
    browser = Rack::Test::Session.new(Rack::MockSession.new(@base.new))
    browser.get("/cache-buster.html")
    browser.last_response.body.count("?").should == 2
  end
end