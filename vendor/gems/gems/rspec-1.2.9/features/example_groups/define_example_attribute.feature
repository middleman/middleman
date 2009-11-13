Feature: Define example attribute

  In order to streamline process
  As an RSpec user
  I want to easily define helper methods that act as a variable assignment
  
  It is fairly common to start with a local variable in one example, use the same
  local variable in the next, and then extract the declaration of that variable
  to before(:each). This requires converting the locals to instance variables.
  
  This feature streamlines the process by defining a helper method so you can extract
  the duplication without having to change other references to the same variables
  to @instance_variables.

  Scenario: 
    Given a file named "counter_spec.rb" with:
    """
    require 'spec/autorun'
    
    class Counter
      def initialize
        @count = 0
      end
      def count
        @count += 1
      end
    end

    describe Counter do
      let(:counter) { Counter.new }
      it "returns 1 the first time" do
        counter.count.should == 1
      end
      it "returns 2 the second time because the counter itself is cached by the 'assign' method" do
        counter.count
        counter.count.should == 2
      end
    end
    """
    When I run "spec counter_spec.rb"
    Then the stdout should include "2 examples, 0 failures"
