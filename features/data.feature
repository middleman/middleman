Feature: Local Data API
  In order to abstract content from structure

  Scenario: Rendering html
    Given the Server is running at "test-app"
    When I go to "/data.html"
    Then I should see "One:Two"
  
  Scenario: Rendering liquid
    Given the Server is running at "test-app"
    When I go to "/data2.html"
    Then I should see "OneTwo"