require 'spec_helper'

module Spec
  describe Runner do
    describe ".configure" do
      it "should yield global configuration" do
        Spec::Runner.configure do |config|
          config.should equal(Spec::Runner.configuration)
        end
      end
    end
  end
end
