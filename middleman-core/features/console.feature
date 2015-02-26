Feature: Console

  Scenario: Enter and exit the console
    Given I run `middleman console` interactively
    When I type "puts 'Hello from the console.'"
    And I type "exit"
    Then it should pass with:
    """
    Hello from the console.
    """
