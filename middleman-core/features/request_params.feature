Feature: Support request parameters
  Scenario: Use request params in a template
    Given the Server is running at "request-app"
    When I go to "/index.html?say=Hello+World"
    Then I should see "Quote Hello World"
    Then I should see "Symbol Hello World"
