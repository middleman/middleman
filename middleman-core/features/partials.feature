Feature: Provide Sane Defaults for Partial Behavior

  Scenario: Finds shared partials relative to the root
    Given the Server is running at "partials-app"
    When I go to "/index.html"
    Then I should see "Header"
    And I should see "Footer"

  Scenario: Finds shared partials relative to the root (sub)
    Given the Server is running at "partials-app"
    When I go to "/sub/index.html"
    Then I should see "Header"
    And I should see "Footer"

  Scenario: Flags error when partial is not found
    Given the Server is running at "partials-app"
    When I go to "/index_missing.html"
    Then I should see "Error: Could not locate partial"

  Scenario: Prefers partials of the same engine type
    Given the Server is running at "partials-app"
    When I go to "/index.html"
    Then I should see "ERb Main"

  Scenario: Prefers partials of the same engine type
    Given the Server is running at "partials-app"
    When I go to "/second.html"
    Then I should see "Str Main"
    And I should see "Header"
    And I should see "Footer"

  Scenario: Finds partial relative to template
    Given the Server is running at "partials-app"
    When I go to "/sub/index.html"
    Then I should see "Local Partial"

  Scenario: Partials can be passed locals
    Given the Server is running at "partials-app"
    When I go to "/locals.html"
    Then I should see "Local var is bar"

  Scenario: Partial and Layout use different engines
    Given the Server is running at "different-engine-partial"
    When I go to "/index.html"
    Then I should see "ERb Header"
    And I should see "Str Footer"

  Scenario: Works with non-template content (svg)
    Given the Server is running at "partials-app"
    When I go to "/svg.html"
    Then I should see "<svg"
    When I go to "/static_underscore.html"
    Then I should see "<p>Hello World</p>"
    When I go to "/code_snippet.html"
    Then I should see "File Not Found"
    When I go to "/_code_snippet.html"
    Then I should see "File Not Found"

Scenario: Works with blocks
    Given the Server is running at "partials-app"
    When I go to "/block.html"
    Then I should see "Start"
    And I should see "Contents"
    And I should see "End"
