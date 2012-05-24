Feature: Build Clean
  Scenario: Build and Clean an app
    Given a fixture app "clean-app"
    And app "clean-app" is using config "empty"
    And a successfully built app at "clean-app"
    Then the following files should exist:
      | build/index.html              |
      | build/should_be_ignored.html  |
      | build/should_be_ignored2.html |
      | build/should_be_ignored3.html |
    And app "clean-app" is using config "complications"
    Given a successfully built app at "clean-app" with flags "--clean"
    Then the following files should not exist:
      | build/should_be_ignored.html  |
      | build/should_be_ignored2.html |
      | build/should_be_ignored3.html |
    And the file "build/index.html" should contain "Comment in layout"

  Scenario: Clean build an app with newly ignored files and a nested output directory
    Given a built app at "clean-nested-app"
    Then a directory named "sub/dir" should exist
    Then the following files should exist:
      | sub/dir/about.html        |
    When I append to "config.rb" with "ignore 'about.html'"
    Given a built app at "clean-nested-app" with flags "--clean"
    Then the following files should not exist:
      | sub/dir/about.html        |
      
