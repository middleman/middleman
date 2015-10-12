Feature: Extension author could use some hooks

  Scenario: When build
    Given a fixture app "extension-api-deprecations-app"
    When I run `middleman build`
    Then the exit status should be 0
    And the output should contain "`set :layout` is deprecated"
    And the file "build/index.html" should contain "In Index"
    And the file "build/index.html" should not contain "In Layout"

