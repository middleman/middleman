Feature: Support liquid partials

  Scenario: Rendering liquid
    Given the Server is running at "test-app"
    When I go to "/liquid_master.html"
    Then I should see "Greetings"