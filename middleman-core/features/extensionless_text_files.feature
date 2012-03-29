Feature: Text Files Without Extensions Should Build and Preview

  Scenario: Building Text Files without directory indexes
  
    Given a fixture app "extensionless-text-files-app"
    And a file named "config.rb" with:
      """
      """
    And a successfully built app at "extensionless-text-files-app"
    When I cd to "build"
    Then the following files should exist:
      | CNAME   |
      | LICENSE |
      | README  |

  Scenario: Building Text Files with directory indexes

    Given a fixture app "extensionless-text-files-app"
    And a file named "config.rb" with:
      """
      activate :directory_indexes
      """
    And a successfully built app at "extensionless-text-files-app"
    When I cd to "build"
    Then the following files should exist:
      | CNAME   |
      | LICENSE |
      | README  |
    Then the following files should not exist:
      | CNAME/index.html   |
      | LICENSE/index.html |
      | README/index.html  |
  
  Scenario: Previewing Text Files without directory indexes
    Given "directory_indexes" feature is "disabled"
    Given the Server is running at "extensionless-text-files-app"
    When I go to "/CNAME"
    Then I should see "test.github.com"
    When I go to "/LICENSE"
    Then I should see "You have the right to remain classy."
    When I go to "/README"
    Then I should see "Bork bork bork"
    
  Scenario: Previewing Text Files with directory indexes
    Given "directory_indexes" feature is "enabled"
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