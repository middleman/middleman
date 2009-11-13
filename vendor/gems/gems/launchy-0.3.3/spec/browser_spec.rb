require File.join(File.dirname(__FILE__),"spec_helper.rb")
require 'stringio'
describe Launchy::Browser do
  it "should find a path to a executable" do
    File.executable?(Launchy::Browser.new.browser).should == true
  end

  it "should handle an http url" do
    Launchy::Browser.handle?("http://www.example.com").should == true
  end

  it "should handle an https url" do
    Launchy::Browser.handle?("https://www.example.com").should == true
  end

  it "should handle an ftp url" do
    Launchy::Browser.handle?("ftp://download.example.com").should == true
  end

  it "should not handle a mailto url" do
    Launchy::Browser.handle?("mailto:jeremy@example.com").should == false
  end

  it "creates a default unix application list" do
    Launchy::Browser.new.nix_app_list.class.should == Array
  end

  { "BROWSER" => "/usr/bin/true",
    "LAUNCHY_BROWSER" => "/usr/bin/true"}.each_pair do |e,v|
    it "can use environmental variable overrides of #{e} for the browser" do
      ENV[e] = v
      Launchy::Browser.new.browser.should eql(v)
      ENV[e] = nil
    end
  end

  it "reports when it cannot find an browser" do
    old_error = $stderr
    $stderr = StringIO.new
    ENV["LAUNCHY_HOST_OS"] = "linux"
    begin
      browser = Launchy::Browser.new
    rescue => e
      e.message.should =~ /Unable to find browser to launch for os family/m
    end
    ENV["LAUNCHY_HOST_OS"] = nil
    $stderr.string.should =~ /Unable to launch. No Browser application found./m
    $stderr = old_error
  end
end
