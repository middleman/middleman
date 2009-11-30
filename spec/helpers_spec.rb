require File.join(File.dirname(__FILE__), "spec_helper")

base = ::Middleman::Base

describe "page_classes helper" do
  it "should generate root paths correctly" do
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/page-class.html")
    browser.last_response.body.chomp.should == "page-class"
  end
  
  it "should generate 1-deep paths correctly" do
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/sub1/page-class.html")
    browser.last_response.body.chomp.should == "sub1 sub1_page-class"
  end

  it "should generate 2-deep paths correctly" do
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/sub1/sub2/page-class.html")
    browser.last_response.body.chomp.should == "sub1 sub1_sub2 sub1_sub2_page-class"
  end
end

describe "auto_stylesheet_link_tag helper" do
  it "should generate root paths correctly" do
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/auto-css.html")
    browser.last_response.body.chomp.should include("stylesheets/auto-css.css")
  end
  
  it "should generate 1-deep paths correctly" do
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/sub1/auto-css.html")
    browser.last_response.body.chomp.should include("stylesheets/sub1/auto-css.css")
  end

  it "should generate 2-deep paths correctly" do
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/sub1/sub2/auto-css.html")
    browser.last_response.body.chomp.should include("stylesheets/sub1/sub2/auto-css.css")
  end
end