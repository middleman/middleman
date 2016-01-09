Feature: Generate mtime-based query string for busting browser caches
  In order to display the most recent content for IE & CDNs and appease YSlow
    
  Scenario: Rendering css with the feature disabled
    Given "cache_buster" feature is "disabled"
    And the Server is running at "cache-buster-app"
    When I go to "/stylesheets/relative_assets.css"
    Then I should see 'blank.gif"'
    
  Scenario: Rendering html with the feature disabled
    Given "cache_buster" feature is "disabled"
    And the Server is running at "cache-buster-app"
    When I go to "/cache-buster.html"
    Then I should see 'site.css"'

  Scenario: Rendering css with the feature enabled
    Given "cache_buster" feature is "enabled"
    And the Server is running at "cache-buster-app"
    When I go to "/stylesheets/relative_assets.css"
    Then I should see "blank.gif?"

  Scenario: Rendering html with the feature enabled
    Given "cache_buster" feature is "enabled"
    And the Server is running at "cache-buster-app"
    When I go to "/cache-buster.html"
    Then I should see "site.css?"
    Then I should see "blank.gif?"

  Scenario: Rendering css with the feature and relative_assets enabled
    Given "relative_assets" feature is "enabled"
    Given "cache_buster" feature is "enabled"
    And the Server is running at "cache-buster-app"
    When I go to "/stylesheets/relative_assets.css"
    Then I should see "blank.gif?"

  Scenario: Rendering html with the feature and relative_assets enabled
    Given "relative_assets" feature is "enabled"
    Given "cache_buster" feature is "enabled"
    And the Server is running at "cache-buster-app"
    When I go to "/cache-buster.html"
    Then I should see "site.css?"
    Then I should see "blank.gif?"

  Scenario: URLs are not rewritten for rewrite ignored paths
    Given a fixture app "cache-buster-app"
    And a file named "config.rb" with:
      """
      activate :cache_buster, rewrite_ignore: [
        '/cache-buster.html',
      ]
      """
    And the Server is running at "cache-buster-app"
    When I go to "/cache-buster.html"
    Then I should see 'site.css"'
    Then I should see 'empty-with-include.js"'
    Then I should see 'blank.gif"'
