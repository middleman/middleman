Feature: Relative Assets
  In order easily switch between relative and absolute paths
    
  Scenario: Rendering css with the feature disabled
    Given "relative_assets" feature is "disabled"
    When I go to "/stylesheets/relative_assets.css"
    Then I should not see "url('../"

  Scenario: Rendering css with the feature enabled
    Given "relative_assets" feature is "enabled"
    When I go to "/stylesheets/relative_assets.css"
    Then I should see "url('../"