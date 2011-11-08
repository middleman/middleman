Feature: Web Fonts

  Scenario: Checking built folder for content
    Given a built app at "fonts-app"
    Then "stylesheets/fonts.css" should exist at "fonts-app" and include "/fonts/StMarie-Thin.otf"
    
  Scenario: Rendering scss
    Given the Server is running at "fonts-app"
    When I go to "/stylesheets/fonts.css"
    Then I should see "/fonts/StMarie-Thin.otf"