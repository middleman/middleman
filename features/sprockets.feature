Feature: Sprockets

  Scenario: Sprockets require
    Given the Server is running at "test-app"
    When I go to "/javascripts/sprockets_base.js"
    Then I should see "sprockets_sub_function"