Feature: Incremental builds

  Scenario: Changing a page should only rebuild that page
    Given a fixture app "incremental-build-app"
    Then build the app tracking dependencies
    Then the output should contain "create  build/standalone.html"
    Then the following files should exist:
      | build/standalone.html |
    When a file named "source/standalone.html.erb" with:
      """
      Updated
      """
    Then build app with only changed
    Then there are "0" files which are "      create  "
    Then there are "1" files which are "     updated  "
    Then the output should contain "updated  build/standalone.html"
    Then the following files should exist:
      | build/standalone.html |

  # Scenario: Changing a layout should rebuild all pages which use that layout
  #   Given a built app tracking dependencies  at "incremental-build-app"
  #   When I cd to "build"
