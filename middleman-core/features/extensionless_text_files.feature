Feature: Text Files Without Extensions Should Build and Preview

  Scenario: Building Text Files without directory indexes
    Given a successfully built app at "extensionless-text-files-app"
    When I cd to "build"
    Then the following files should exist:
      | CNAME   |
      | LICENSE |
      | README  |




  Scenario: Previewing Text Files
    Given the Server is running at "extensionless-text-files-app"
    When I go to "/CNAME"
    Then I should see "test.github.com"
    When I go to "/LICENSE"
    Then I should see "You have the right to remain classy."
    When I go to "/README"
    Then I should see "Bork bork bork"
    # When I go to "/CNAME/index.html"
    # Then I should see "File Not Found"
    # When I go to "/LICENSE/index.html"
    # Then I should see "File Not Found"
    # When I go to "/README/index.html"
    # Then I should see "File Not Found"