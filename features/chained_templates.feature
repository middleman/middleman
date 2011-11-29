Feature: Templates should be chainable
  In order to insert variables and data in "static" engines

  Scenario: Data in Erb in Markdown
    Given the Server is running at "chained-app"
    When I go to "/index.html"
    Then I should see "Title</h1>"
    And I should see "Subtitle</h2>"
    And I should see "Sup</h3>"
    
  Scenario: Build chained template
    Given a built app at "chained-app"
    Then "index.html" should exist at "chained-app" and include "Title</h1>"
    Then "index.html" should exist at "chained-app" and include "Subtitle</h2>"
    Then "index.html" should exist at "chained-app" and include "Sup</h3>"