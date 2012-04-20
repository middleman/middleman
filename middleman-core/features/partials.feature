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

  Scenario: Finds shared partials without _ prefix
    Given the Server is running at "partials-app"
    When I go to "/using_snippet.html"
    Then I should see "Snippet"
    
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
