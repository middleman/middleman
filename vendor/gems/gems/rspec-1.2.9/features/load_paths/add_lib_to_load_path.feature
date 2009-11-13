Feature: add ./lib to load path
  In order to ...
  As a spec author
  I want rspec to add ./lib to the load path

  Scenario: spec helper
    Given a directory named "spec"
    And a file named "example.rb" with:
      """
      describe $LOAD_PATH do
        it "begins with 'lib' in the current directory in the load path" do
          libdir = File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
          $LOAD_PATH.should include(libdir)
        end
      end
      """
    When I run "spec example.rb"
    Then the stdout should include "1 example, 0 failures"
    And  the exit code should be 0

