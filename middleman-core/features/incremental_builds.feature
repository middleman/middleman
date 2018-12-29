Feature: Incremental builds

  Scenario: Changing a page should only rebuild that page
    Given an empty app
    When a file named "config.rb" with:
      """
      """
    When a file named "source/standalone.html.erb" with:
      """
      Initial
      """
    When a file named "source/other.html.erb" with:
      """
      Some other file
      """
    Then build the app tracking dependencies
    Then the output should contain "create  build/standalone.html"
    Then the following files should exist:
      | build/standalone.html |
    And the file "build/standalone.html" should contain "Initial"
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
    And the file "build/standalone.html" should contain "Updated"

  Scenario: Changing a layout should only rebuild pages which use that layout
    Given an empty app
    When a file named "config.rb" with:
      """
      """
    When a file named "source/layout.erb" with:
      """
      Initial
      <%= yield %>
      """
    When a file named "source/page1.html.erb" with:
      """
      Page 1
      """
    When a file named "source/page2.html.erb" with:
      """
      Page 2
      """
    When a file named "source/no-layout.html.erb" with:
      """
      ---
      layout: false
      ---

      Another page
      """
    Then build the app tracking dependencies
    Then the output should contain "create  build/page1.html"
    Then the output should contain "create  build/page2.html"
    Then the following files should exist:
      | build/page1.html |
      | build/page2.html |
    And the file "build/page1.html" should contain "Initial"
    And the file "build/page1.html" should contain "Page 1"
    And the file "build/page2.html" should contain "Initial"
    And the file "build/page2.html" should contain "Page 2"
    When a file named "source/layout.erb" with:
      """
      Updated
      <%= yield %>
      """
    Then build app with only changed
    Then there are "0" files which are "      create  "
    Then there are "2" files which are "     updated  "
    Then the output should contain "updated  build/page1.html"
    Then the output should contain "updated  build/page2.html"
    Then the following files should exist:
      | build/page1.html |
      | build/page2.html |
    And the file "build/page1.html" should contain "Updated"
    And the file "build/page1.html" should contain "Page 1"
    And the file "build/page2.html" should contain "Updated"
    And the file "build/page2.html" should contain "Page 2"