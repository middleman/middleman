Feature: Alternate between multiple asset hosts
  In order to speed up page loading
  
  Scenario: Rendering css with the feature enabled
    Given I am using an asset host
    And the Server is running at "test-app"
    When I go to "/stylesheets/asset_host.css"
    Then I should see "http://assets"
    
  Scenario: Rendering html with the feature enabled
    Given I am using an asset host
    And the Server is running at "test-app"
    When I go to "/asset_host.html"
    Then I should see "http://assets"