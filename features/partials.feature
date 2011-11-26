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

  Scenario: Prefers partials of the same engine type
    Given the Server is running at "partials-app"
    When I go to "/index.html"
    Then I should see "ERb Main"
  
  Scenario: Prefers partials of the same engine type
    Given the Server is running at "partials-app"
    When I go to "/second.html"
    Then I should see "Haml Main"
    And I should see "Header"
    And I should see "Footer"
    
  Scenario: Finds partial relative to template
    Given the Server is running at "partials-app"
    When I go to "/sub/index.html"
    Then I should see "Local Partial"