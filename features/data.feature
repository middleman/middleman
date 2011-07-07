Feature: Local Data API
  In order to abstract content from structure

  Scenario: Rendering html
    Given the Server is running
    When I go to "/data.html"
    Then I should see "One:Two"