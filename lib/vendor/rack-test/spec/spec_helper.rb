require "rubygems"
require "spec"

gem "rack", "~> 1.0.0"

require File.expand_path(File.dirname(__FILE__) + "/../lib/rack/test")
require File.dirname(__FILE__) + "/fixtures/fake_app"

Spec::Runner.configure do |config|
  config.include Rack::Test::Methods

  def app
    Rack::Lint.new(Rack::Test::FakeApp.new)
  end

end

describe "any #verb methods", :shared => true do
  it "requests the URL using VERB" do
    send(verb, "/")

    last_request.env["REQUEST_METHOD"].should == verb.upcase
    last_response.should be_ok
  end

  it "uses the provided env" do
    send(verb, "/", {}, { "User-Agent" => "Rack::Test" })
    last_request.env["User-Agent"].should == "Rack::Test"
  end

  it "yields the response to a given block" do
    yielded = false

    send(verb, "/") do |response|
      response.should be_ok
      yielded = true
    end

    yielded.should be_true
  end

  context "for a XHR" do
    it "sends XMLHttpRequest for the X-Requested-With header" do
      send(verb, "/", {}, { :xhr => true })
      last_request.env["X-Requested-With"].should == "XMLHttpRequest"
    end
  end
end
