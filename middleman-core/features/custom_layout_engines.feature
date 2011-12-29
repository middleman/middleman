Feature: Custom Layout Engine

  Scenario: Checking built folder for content
    Given a successfully built app at "custom-layout-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html                                    |
    And the file "index.html" should contain "Comment in layout"