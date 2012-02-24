Feature: Compass sprites should be generated on build and copied
  Scenario: Building a clean site with sprites
    Given a successfully built app at "compass-sprites-app"
    When I cd to "build"
    Then the following files should exist:
      | images/icon-s1a8aa64128.png |