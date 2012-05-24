Feature: Alternate between multiple asset hosts
  In order to speed up page loading
    
  Scenario: Rendering html with the feature enabled
    Given the Server is running at "asset-host-app"
    When I go to "/asset_host.html"
    Then I should see "http://assets"