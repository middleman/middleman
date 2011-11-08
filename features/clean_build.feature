Feature: Build Clean
  Scenario: Build and Clean an app
    Given app "clean-app" is using config "empty"
    And a built app at "clean-app"
    And app "clean-app" is using config "complications"
    And a built app at "clean-app" with flags "--clean"
    Then "should_be_ignored.html" should not exist at "clean-app"
    And "should_be_ignored2.html" should not exist at "clean-app"
    And "should_be_ignored3.html" should not exist at "clean-app"
