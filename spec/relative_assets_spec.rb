require 'rack/test'
require File.join(File.dirname(__FILE__), "spec_helper")

base = ::Middleman::Base
base.set :root, File.join(File.dirname(__FILE__), "fixtures", "sample")

describe "Relative Assets Feature" do
  it "should not contain ../ if off" do
    base.disable :relative_assets
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/stylesheets/relative_assets.css")
    browser.last_response.body.should_not include("../")
  end
  
  it "should contain ../ if on" do
    base.enable :relative_assets
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/stylesheets/relative_assets.css")
    browser.last_response.body.should include("../")
  end
end