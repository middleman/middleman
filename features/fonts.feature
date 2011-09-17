Feature: Web Fonts

  Scenario: Checking built folder for content
    Given a built app at "test-app"
    Then "stylesheets/fonts.css" should exist at "test-app" and include "/fonts/StMarie-Thin.otf"
    And cleanup built app at "test-app"
    
  Scenario: Rendering scss
    Given the Server is running at "test-app"
    When I go to "/stylesheets/fonts.css"
    Then I should see "/fonts/StMarie-Thin.otf"