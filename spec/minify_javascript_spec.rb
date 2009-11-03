require 'rack/test'
require File.join(File.dirname(__FILE__), "spec_helper")

base = ::Middleman::Base
base.set :root, File.join(File.dirname(__FILE__), "fixtures", "sample")

describe "Minify Javascript Feature" do
  it "should not minify inline js if off" do
    base.disable :minify_javascript
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/inline-js.html")
    browser.last_response.body.chomp.split($/).length.should == 10
  end
  
  it "should minify inline js if on" do
    base.enable :minify_javascript
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/inline-js.html")
    browser.last_response.body.chomp.split($/).length.should == 1
  end
end