Feature: Middleman should serve plain directories without config

  Scenario: Preview a folder of static pages
    Given the Server is running at "plain-app"
    When I go to "/index.html"
    Then I should see "I am index"