Feature: Setting page settings through frontmatter
  Scenario: Setting layout, ignoring, and disabling directory indexes through frontmatter
    Given a successfully built app at "frontmatter-settings-app"
    Then the following files should exist:
      | build/proxied/index.html  |
      | build/no_index.html       |
    And the file "build/alternate_layout/index.html" should contain "Alternate layout"
    And the following files should not exist:
      | build/ignored/index.html  |
      | build/no_index/index.html |