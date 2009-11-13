Feature: spec helper
  In order to centralize code needed across most specs
  As a spec author
  I want to require 'spec_helper'
  
  Because rspec adds the PROJECT_ROOT/spec directory to the load path, we can
  just require 'spec_helper' and it will be found.

  Scenario: spec helper
    Given a directory named "spec"
    And a file named "spec/spec_helper.rb" with:
      """
      SOME_CONSTANT = 'some value'
      """
    And a file named "example.rb" with:
      """
      require 'spec_helper'
      describe SOME_CONSTANT do
        it { should == 'some value' }
      end
      """
    When I run "spec example.rb"
    And  the stdout should include "1 example, 0 failures"
    And  the exit code should be 0

