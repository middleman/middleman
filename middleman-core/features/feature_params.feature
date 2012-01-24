Feature: Be able to pass params to extensions
  Scenario: Read some simple variables
    Given the Server is running at "feature-params-app"
    When I go to "/index.html"
    Then I should see "hello: world"
    And I should see "hola: mundo"