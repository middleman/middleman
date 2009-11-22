Feature: Custom layouts
  In order easily switch between relative and absolute paths
  
  Scenario: Using custom :layout attribute
    Given page "/custom-layout.html" has layout "custom"
    When I go to "/custom-layout.html"
    Then I should see "Custom Layout"
    
  Scenario: Using with_layout block
    Given "/custom-layout.html" with_layout block has layout "custom"
    When I go to "/custom-layout.html"
    Then I should see "Custom Layout"