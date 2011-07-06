Feature: Local Data API
  In order to abstract content from structure

  Scenario: Rendering html with the feature enabled
    Given the Server is running
    When I go to "/data.html"
    Then I should see "One:Two"