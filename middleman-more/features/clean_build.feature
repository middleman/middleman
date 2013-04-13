Feature: Build Clean

  Scenario: Clean an app with directory indexes
    Given a successfully built app at "clean-dir-app" with flags "--no-clean"
    Then the following files should exist:
      | build/about/index.html        |
    Given a successfully built app at "clean-dir-app"
    Then the following files should exist:
      | build/about/index.html        |

  Scenario: Clean build an app that's never been built
    Given a successfully built app at "clean-dir-app"
    Then the following files should exist:
      | build/about/index.html        |