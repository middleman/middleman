Feature: Custom layouts
  In order easily switch between relative and absolute paths
  
  Scenario: Using custom :layout attribute
    Given page "/custom-layout.html" has layout "custom"
    And the Server is running at "test-app"
    When I go to "/custom-layout.html"
    Then I should see "Custom Layout"
    
  Scenario: Using with_layout block
    Given "/custom-layout.html" with_layout block has layout "custom"
    And the Server is running at "test-app"
    When I go to "/custom-layout.html"
    Then I should see "Custom Layout"
    
  Scenario: Using custom :layout attribute with folders
    Given page "/custom-layout-dir/" has layout "custom"
    And the Server is running at "test-app"
    When I go to "/custom-layout-dir"
    Then I should see "Custom Layout"
    When I go to "/custom-layout-dir/"
    Then I should see "Custom Layout"
    When I go to "/custom-layout-dir/index.html"
    Then I should see "Custom Layout"
    
  Scenario: Using custom :layout attribute with folders
    Given page "/custom-layout-dir" has layout "custom"
    And the Server is running at "test-app"
    When I go to "/custom-layout-dir"
    Then I should see "Custom Layout"
    When I go to "/custom-layout-dir/"
    Then I should see "Custom Layout"
    When I go to "/custom-layout-dir/index.html"
    Then I should see "Custom Layout"
    
  Scenario: Using custom :layout attribute with folders
    Given page "/custom-layout-dir/index.html" has layout "custom"
    And the Server is running at "test-app"
    When I go to "/custom-layout-dir"
    Then I should see "Custom Layout"
    When I go to "/custom-layout-dir/"
    Then I should see "Custom Layout"
    When I go to "/custom-layout-dir/index.html"
    Then I should see "Custom Layout"