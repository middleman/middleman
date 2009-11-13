Feature: Search
  In order to learn cucumber
  As an engineer
  I want to run some simple tests

  Scenario: 1) Reverse a String
    Given a string "abc"
    When the string is reversed
    Then the string should be "cba"
    
  More Examples:
    |input |output|
    |a     |a     |
    |ab    |ba    |    

  Scenario: 2) Upcase a String
    Given a string "abc"
    When the string is upcased
    Then the string should be "ABC"

  Scenario: 3) Combining 2 Methods
    Given a string "abc"
    When the string is upcased
    And the string is reversed
    Then the string should be "CBA"