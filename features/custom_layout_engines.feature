Feature: Custom Layout Engine

  Scenario: Checking built folder for content
    Given a built app at "custom-layout-app"
    Then "index.html" should exist at "custom-layout-app" and include "Comment in layout"
    
  Scenario: Checking server for content
    Given the Server is running at "test-app"
    When I go to "/index.html"
    Then I should see "Comment in layout"