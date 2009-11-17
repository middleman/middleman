Feature: stub and mock together

  As an RSpec user
  I want to use stubs and mocks together

  Scenario: stub in before
    Given a file named "stub_and_mocks_spec.rb" with:
      """
      describe "a stub in before" do
        before(:each) do
          @messenger = mock('messenger').as_null_object
        end

        it "a" do
          @messenger.should_receive(:foo).with('first')
          @messenger.foo('second')
          @messenger.foo('third')
        end
      end
      """
    When I run "spec stub_and_mocks_spec.rb --format nested"
    Then the stdout should include "received :foo with unexpected arguments\n  expected: (\"first\")\n       got: ([\"second\"], [\"third\"])"
