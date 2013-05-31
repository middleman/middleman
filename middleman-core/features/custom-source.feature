Feature: Support customizing the source directory name

  Scenario: Layouts don't try to build
    Given a successfully built app at "custom-src-app"
    When I cd to "build"
    Then the following files should not exist:
      | layouts/layout.html |
