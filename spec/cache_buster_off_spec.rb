require File.join(File.dirname(__FILE__), "spec_helper")
  
describe "Cache Buster Feature in CSS" do
  before do
    base = ::Middleman::Base
    base.set :root, File.join(File.dirname(__FILE__), "fixtures", "sample")
    base.disable :cache_buster
    @browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
  end

  it "should not append query string in CSS if off" do
    @browser.get("/stylesheets/relative_assets.css")
    @browser.last_response.body.count("?").should == 0
  end
  
  it "should not append query string in HTML if off" do
    @browser.get("/cache-buster.html")
    @browser.last_response.body.count("?").should == 0
  end
end