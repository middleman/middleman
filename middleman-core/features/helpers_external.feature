Feature: Helpers in external files

  Scenario: Hello Helper
    Given the Server is running at "external-helpers"
    Then going to "/index.html" should not raise an exception
    And I should see "Hello World"