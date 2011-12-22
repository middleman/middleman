Feature: Custom Layout Engine

  Scenario: Checking built folder for content
    Given a successfully built app at "custom-layout-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html                                    |
    And the file "index.html" should contain "Comment in layout"
    
  Scenario: Checking server for content
    Given the Server is running at "test-app"
    When I go to "/index.html"
    Then I should see "Comment in layout"