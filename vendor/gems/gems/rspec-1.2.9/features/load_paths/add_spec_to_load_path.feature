Feature: add 'spec' to load path
  In order to ...
  As a spec author
  I want rspec to add 'spec to the load path

  Scenario: add 'spec' to load path
    Given a directory named "spec"
    And a file named "example.rb" with:
      """
      describe $LOAD_PATH do
        it "includes with 'spec' in the current directory in the load path" do
          specdir = File.expand_path(File.join(File.dirname(__FILE__), 'spec'))
          $LOAD_PATH.should include(specdir)
        end
      end
      """
    When I run "spec example.rb"
    Then the stdout should include "1 example, 0 failures"
    And  the exit code should be 0

