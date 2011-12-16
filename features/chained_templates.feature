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
    
    Then a directory named "build" should exist
    And the exit status should be 0

    When I cd to "build"
    Then the following files should exist:
      | index.html                                    |

    And the file "index.html" should contain "Title</h1>"
    And the file "index.html" should contain "Subtitle</h2>"
    And the file "index.html" should contain "Sup</h3>"