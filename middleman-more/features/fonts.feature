Feature: Web Fonts

  Scenario: Checking built folder for content
    Given a successfully built app at "fonts-app"
    When I cd to "build"
    Then the following files should exist:
      | stylesheets/fonts.css                         |
    And the file "stylesheets/fonts.css" should contain "/fonts/StMarie-Thin.otf"
    
  Scenario: Rendering scss
    Given the Server is running at "fonts-app"
    When I go to "/stylesheets/fonts.css"
    Then I should see "/fonts/StMarie-Thin.otf"