require File.join(File.dirname(__FILE__), "spec_helper")

base = ::Middleman::Base
base.set :root, File.join(File.dirname(__FILE__), "fixtures", "sample")

describe "Custom layout" do
  it "should use custom layout" do
    base.page "/custom-layout.html", :layout => :custom
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/custom-layout.html")
    browser.last_response.body.should include("Custom Layout")
  end
  
  it "should use custom layout with_layout method" do
    base.with_layout :layout => :custom do
      page "/custom-layout.html"
    end
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/custom-layout.html")
    browser.last_response.body.should include("Custom Layout")
  end
end