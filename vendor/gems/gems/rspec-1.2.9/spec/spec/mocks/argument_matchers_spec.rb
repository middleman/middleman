require 'spec_helper'

module Spec
  module Mocks
    module ArgumentMatchers
      describe AnyArgsMatcher do
        it "represents itself nicely for failure messages" do
          AnyArgsMatcher.new.description.should == "any args"
        end
      end

      describe AnyArgMatcher do
        it "represents itself nicely for failure messages" do
          AnyArgMatcher.new(nil).description.should == "anything"
        end
      end
    end
  end
end