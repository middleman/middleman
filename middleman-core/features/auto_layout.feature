Feature: Provide Sane Defaults for Layout Behavior

  Scenario: Template and Layout of same engine exist
    Given the Server is running at "engine-matching-layout"
    When I go to "/index.html"
    Then I should see "Comment in layout"
  
  Scenario: Template and Layout of different engine
    Given the Server is running at "different-engine-layout"
    When I go to "/index.html"
    Then I should see "Comment in layout"
  
  Scenario: Multiple layouts exist, prefer same engine
    Given the Server is running at "multiple-layouts"
    When I go to "/index.html"
    Then I should see "ERb Comment in layout"
  
  Scenario: No layout exists
    Given the Server is running at "no-layout"
    When I go to "/index.html"
    Then I should not see "Comment in layout"
  
  Scenario: Manually set default layout in config (exists)
    Given the Server is running at "manual-layout"
    When I go to "/index.html"
    Then I should see "Custom Comment in layout"
    
  Scenario: Manually set default layout in config (does not exist)
    Given the Server is running at "manual-layout-missing"
    When I go to "/index.html"
    Then I should see "Error"
  
  Scenario: Overwrite manual layout
    Given the Server is running at "manual-layout-override"
    When I go to "/index.html"
    Then I should see "Another Comment in layout"