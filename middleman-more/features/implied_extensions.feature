Feature: More default extensions

  Scenario: Default extensions preview
    Given the Server is running at "implied-extensions-app"
    When I go to "/test.html"
    Then I should see "Hello"
    When I go to "/test2.html"
    Then I should see "World"
    When I go to "/test3.html"
    Then I should see "Howdy"
    When I go to "/test4.html"
    Then I should see "HELLO"
    When I go to "/javascripts/app.js"
    Then I should see "derp"
    When I go to "/stylesheets/style.css"
    Then I should see "section"
    When I go to "/stylesheets/style2.css"
    Then I should see "section"
    When I go to "/stylesheets/style3.css"
    Then I should see "color"
  
  Scenario: Default extensions build
    Given a fixture app "implied-extensions-app"
    And a successfully built app at "implied-extensions-app"
    When I cd to "build"
    Then the following files should exist:
      | test.html              |
      | test2.html             |
      | test3.html             |
      | test4.html             |
      | javascripts/app.js     |
      | stylesheets/style.css  |
      | stylesheets/style2.css |
      | stylesheets/style3.css |
    And the file "test.html" should contain "Hello"
    And the file "test2.html" should contain "World"
    And the file "test3.html" should contain "Howdy"
    And the file "test4.html" should contain "HELLO"
    And the file "javascripts/app.js" should contain "derp"
    And the file "stylesheets/style.css" should contain "section"
    And the file "stylesheets/style2.css" should contain "section"
    And the file "stylesheets/style3.css" should contain "color"