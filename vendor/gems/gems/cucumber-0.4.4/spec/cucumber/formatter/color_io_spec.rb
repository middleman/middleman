require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/formatter/color_io'

module Cucumber
  module Formatter
    describe ColorIO do
      describe "<<" do
        it "should convert to a print using kernel" do
          color_io = ColorIO.new
          
          Kernel.should_receive(:print).with("monkeys")
          
          color_io << "monkeys"
        end
        
        it "should allow chained <<" do
          color_io = ColorIO.new

          Kernel.should_receive(:print).with("monkeys")
          Kernel.should_receive(:print).with(" are tasty")
          
          color_io << "monkeys" <<  " are tasty"
        end
      end
    end
  end
end
