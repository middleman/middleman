require 'spec_helper'

module Spec
  module Mocks
    describe "Example with stubbed and then called message" do
      it "fails if the message is expected and then subsequently not called again" do
        mock_obj = mock("mock", :msg => nil)
        mock_obj.msg
        mock_obj.should_receive(:msg)
        lambda { mock_obj.rspec_verify }.should raise_error(Spec::Mocks::MockExpectationError)
      end

      it "outputs arguments of all similar calls" do
        m = mock('mock', :foo => true)
        m.should_receive(:foo).with('first')
        m.foo('second')
        m.foo('third')
        lambda do
          m.rspec_verify
        end.should raise_error(%Q|Mock "mock" received :foo with unexpected arguments\n  expected: ("first")\n       got: (["second"], ["third"])|)
        m.rspec_reset
      end
    end
    
  end
end