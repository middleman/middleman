Feature: Console

  Scenario: Enter and exit the console
    Given a fixture app "large-build-app"
    When I run `middleman console` interactively
    And I type "puts 'Hello from the console.'"
    And I type "exit"
    Then it should pass with:
    """
    Hello from the console.
    """
