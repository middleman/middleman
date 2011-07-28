Feature: Generate mtime-based query string for busting browser caches
  In order to display the most recent content for IE & CDNs and appease YSlow
    
  Scenario: Rendering css with the feature disabled
    Given "cache_buster" feature is "disabled"
    And the Server is running at "test-app"
    When I go to "/stylesheets/relative_assets.css"
    Then I should not see "?"
    
  Scenario: Rendering html with the feature disabled
    Given "cache_buster" feature is "disabled"
    And the Server is running at "test-app"
    When I go to "/cache-buster.html"
    Then I should not see "?"

  Scenario: Rendering css with the feature enabled
    Given "cache_buster" feature is "enabled"
    And the Server is running at "test-app"
    When I go to "/stylesheets/relative_assets.css"
    Then I should see "?"

  Scenario: Rendering html with the feature enabled
    Given "cache_buster" feature is "enabled"
    And the Server is running at "test-app"
    When I go to "/cache-buster.html"
    Then I should not see "?"