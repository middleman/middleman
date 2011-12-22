Feature: Allow config.rb and extensions to add CLI commands
  Scenario: Test 3rd Party Command
    Given a fixture app "3rd-party-command"
    When I run `middleman hello`
    Then the output should contain "Hello World"