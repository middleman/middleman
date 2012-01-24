Feature: Alternate between multiple asset hosts
  In order to speed up page loading
  
  Scenario: Rendering css with the feature enabled
    Given the Server is running at "asset-host-app"
    When I go to "/stylesheets/asset_host.css"
    Then I should see "http://assets"