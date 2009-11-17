require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/wire_support/wire_language'

module Cucumber
  module WireSupport
    describe WirePacket do
      it "should convert to JSON" do
        packet = WirePacket.new('test_message', :foo => :bar)
        packet.to_json.should == "[\"test_message\",{\"foo\":\"bar\"}]"
      end
      
      describe ".parse" do
        it "should understand a raw packet containing no arguments" do
          packet = WirePacket.parse("[\"test_message\",null]")
          packet.message.should == 'test_message'
          packet.params.should be_nil
        end
        
        it "should understand a raw packet containging arguments data" do
          packet = WirePacket.parse("[\"test_message\",{\"foo\":\"bar\"}]")
          packet.params['foo'].should == 'bar'
        end
      end
    end
  end
end