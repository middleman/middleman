Feature: Build Clean
  Scenario: Build and Clean an app
    Given a fixture app "clean-app"
    And app "clean-app" is using config "empty"
    And a successfully built app at "clean-app"
    And app "clean-app" is using config "complications"
    
    Given a successfully built app at "clean-app" with flags "--clean"
    When I cd to "build"
    Then the following files should not exist:
      | should_be_ignored.html                        |
      | should_be_ignored2.html                       |
      | should_be_ignored3.html                       |
    And the file "index.html" should contain "Comment in layout"

  Scenario: Clean an app with directory indexes
    Given a successfully built app at "clean-dir-app"
    When I cd to "build"
    Then the following files should exist:
      | about/index.html                               |
    
    Given a successfully built app at "clean-dir-app" with flags "--clean"
      When I cd to "build"
    Then the following files should exist:
      | about/index.html                               |

  Scenario: Clean build an app that's never been built
    Given a successfully built app at "clean-dir-app" with flags "--clean"
    When I cd to "build"
    Then the following files should exist:
      | about/index.html                               |
