Feature: Setting page settings through frontmatter
  Scenario: Setting layout, ignoring, and disabling directory indexes through frontmatter (build)
    Given a successfully built app at "frontmatter-settings-app"
    Then the following files should exist:
      | build/proxied/index.html  |
      | build/no_index.html       |
    And the file "build/alternate_layout/index.html" should contain "Alternate layout"
    And the following files should not exist:
      | build/ignored/index.html  |
      | build/no_index/index.html |
    
    
  Scenario: Setting layout, ignoring, and disabling directory indexes through frontmatter (preview)
    Given the Server is running at "frontmatter-settings-app"
    # When I go to "/proxied/"
    # Then I should not see "File Not Found"
    When I go to "/no_index.html"
    Then I should not see "File Not Found"
    When I go to "/alternate_layout/"
    Then I should not see "File Not Found"
    And I should see "Alternate layout"
    When I go to "/ignored.html"
    Then I should see "File Not Found"
    When I go to "/ignored/index.html"
    Then I should see "File Not Found"
    When I go to "/no_index/index.html"
    Then I should see "File Not Found"

  Scenario: Changing frontmatter in preview server
    Given the Server is running at "frontmatter-settings-app"
    When I go to "/ignored/index.html"
    Then I should see "File Not Found"
    And the file "source/ignored.html.erb" has the contents
      """
      ---
      ignored: false
      ---

      This file is no longer ignored.
      """
    When I go to "/ignored/index.html"
    Then I should see "This file is no longer ignored."