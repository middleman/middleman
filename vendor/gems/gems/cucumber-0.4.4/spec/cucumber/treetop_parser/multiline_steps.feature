Feature: Multiline steps should work

  Scenario: Reading a table
    Given the following table
      | where | why     |
      | Oslo  | born    |
      | London| working |
    Then I should be working in London
    And I should be born in Oslo
    And I should be able to expect
      """
      A string
        that "indents"
      and spans
      several lines
      
      """