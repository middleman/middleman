Feature: Sinatra Routes

  Scenario: Rendering html
    Given the Server is running
    When I go to "/sinatra_test"
    Then I should see "Ratpack"