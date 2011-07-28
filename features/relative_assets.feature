Feature: Relative Assets
  In order easily switch between relative and absolute paths
    
  Scenario: Rendering css with the feature disabled
    Given "relative_assets" feature is "disabled"
    And the Server is running at "test-app"
    When I go to "/stylesheets/relative_assets.css"
    Then I should not see "url('../"
    And I should see "/images/blank.gif"
    
  Scenario: Rendering html with the feature disabled
    Given "relative_assets" feature is "disabled"
    And the Server is running at "test-app"
    When I go to "/relative_image.html"
    Then I should see "/images/blank.gif"

  Scenario: Rendering css with the feature enabled
    Given "relative_assets" feature is "enabled"
    And the Server is running at "test-app"
    When I go to "/stylesheets/relative_assets.css"
    Then I should see "url('../images/blank.gif"
    
  Scenario: Rendering html with the feature disabled
    Given "relative_assets" feature is "enabled"
    And the Server is running at "test-app"
    When I go to "/relative_image.html"
    Then I should not see "/images/blank.gif"
    And I should see "images/blank.gif"
    
  Scenario: Rendering html with a custom images_dir
    Given "relative_assets" feature is "enabled"
    And "images_dir" is set to "img"
    And the Server is running at "test-app"
    When I go to "/stylesheets/relative_assets.css"
    Then I should see "url('../img/blank.gif"
    
  Scenario: Rendering css with a custom images_dir
    Given "relative_assets" feature is "enabled"
    And "images_dir" is set to "img"
    And the Server is running at "test-app"
    When I go to "/relative_image.html"
    Then I should not see "/images/blank.gif"
    Then I should not see "/img/blank.gif"
    And I should see "img/blank.gif"