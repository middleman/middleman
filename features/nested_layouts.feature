Feature: Allow nesting of layouts

  Scenario: A page uses an inner layout when uses an outer layout
    Given the Server is running at "nested-layout-app"
    When I go to "/index.html"
    Then I should see "Template"
    And I should see "Inner"
    And I should see "Outer"
    And I should see "Master"

  Scenario: YAML Front Matter isn't clobbered with nested layouts
    Given the Server is running at "nested-layout-app"
    When I go to "/data-one.html"
    Then I should see "Page Number One"
    When I go to "/data-two.html"
    Then I should see "Page Number Two"
    When I go to "/data-one.html"
    Then I should see "Page Number One"
    When I go to "/data-two.html"
