require File.join(File.dirname(__FILE__), "spec_helper")

base = ::Middleman::Base
base.set :root, File.join(File.dirname(__FILE__), "fixtures", "sample")

describe "Minify Javascript Feature" do
  it "should not minify inline css if off" do
    base.disable :minify_css
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/inline-css.html")
    browser.last_response.body.chomp.split($/).length.should == 3
  end
  
  it "should minify inline css if on" do
    base.enable :minify_css
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/inline-css.html")
    browser.last_response.body.chomp.split($/).length.should == 1
  end
end