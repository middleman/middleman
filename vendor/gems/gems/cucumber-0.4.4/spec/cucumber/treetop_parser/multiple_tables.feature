Feature: Addition
  In order to avoid silly mistakes
  As a math idiot
  I want to be told the sum of two numbers

  Scenario: Add two numbers
    Given I have entered 50 into the calculator
    And I have entered 70 into the calculator
    When I press add
    Then the result should be 120 on the screen

  More Examples:
    | input_1 | input_2 | button | output |
    | 20      | 30      | add    | 50     |
    | 2       | 5       | add    | 7      |
    | 0       | 40      | add    | 40     |

  Scenario: Add three numbers
    Given I have entered 25 into the calculator
    And I have entered 12 into the calculator
    And I have entered 13 into the calculator
    When I press add
    Then the result should be 50 on the screen

  More Examples:
    | input_1 | input_2 | input_3 | button | output |
    | 1       | 2       | 3       | add    | 6      |
