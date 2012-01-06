Feature: Compass sprites should be generated on build and copied
  Scenario: Building a clean site with sprites
    Given a successfully built app at "compass-sprites-app"
    Then the output should contain "images/icon-"