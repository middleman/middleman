require 'rack/test'
require File.join(File.dirname(__FILE__), "spec_helper")

base = ::Middleman::Base
base.set :root, File.join(File.dirname(__FILE__), "fixtures", "sample")

describe "Auto Image sizes Feature" do
  it "should not append width and height if off" do
    base.disable :automatic_image_sizes
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/auto-image-sizes.html")
    browser.last_response.body.should_not include("width=")
    browser.last_response.body.should_not include("height=")
  end
  
  it "should append width and height if off" do
    base.enable :automatic_image_sizes
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/auto-image-sizes.html")
    browser.last_response.body.should include("width=")
    browser.last_response.body.should include("height=")
  end
end