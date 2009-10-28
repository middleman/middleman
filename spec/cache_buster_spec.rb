require 'rack/test'
require File.join(File.dirname(__FILE__), "spec_helper")

base = ::Middleman::Base
base.set :root, File.join(File.dirname(__FILE__), "fixtures", "sample")

describe "Cache Buster Feature" do
  it "should not append query string if off" do
    base.disable :cache_buster
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/stylesheets/relative_assets.css")
    browser.last_response.body.should_not include("?")
  end
  
  it "should append query string if on" do
    base.enable :cache_buster
    browser = Rack::Test::Session.new(Rack::MockSession.new(base.new))
    browser.get("/stylesheets/relative_assets.css")
    browser.last_response.body.should include("?")
  end
end