Feature: Extension author could use some hooks

  Scenario: When build
    Given a successfully built app at "extension-api-deprecations-app"
    And the output should contain "`set :layout` is deprecated"
    And the file "build/index.html" should contain "In Index"
    And the file "build/index.html" should not contain "In Layout"

