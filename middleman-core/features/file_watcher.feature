Feature: The On-Disk File Watcher

  Scenario: File changes should be tracked
    Given the File Watcher is running
    And the Server is running at "file-change-app"
    When I go to "/index.html"
    Then I should see "Home Page"
    And the file "source/index.html.erb" has the contents
      """
      Something else
      """
    When I go to "/index.html"
    Then I should not see "Home Page"
    Then I should see "Something else"

  Scenario: File additions should be tracked
    Given the File Watcher is running
    And the Server is running at "file-change-app"
    When I go to "/test.html"
    Then I should see "File Not Found"
    And the file "source/test.html.erb" has the contents
      """
      Derp de doo
      """
    When I go to "/test.html"
    Then I should not see "File Not Found"
    Then I should see "Derp de doo"

  Scenario: File removals should be tracked
    Given the File Watcher is running
    And the Server is running at "file-change-app"
    When I go to "/about.html"
    Then I should see "About Page"
    And the file "source/about.html.erb" is removed
    When I go to "/about.html"
    Then I should not see "About Page"
    Then I should see "File Not Found"
