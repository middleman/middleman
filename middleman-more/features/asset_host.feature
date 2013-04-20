Feature: Alternate between multiple asset hosts
  In order to speed up page loading
  
  Scenario: Set single host globally
    Given a fixture app "asset-host-app"
    And a file named "config.rb" with:
      """
      activate :asset_host
      set :asset_host, "http://assets1.example.com"
      """
    And the Server is running
    When I go to "/asset_host.html"
    Then I should see "http://assets1"
    When I go to "/stylesheets/asset_host.css"
    Then I should see "http://assets1"

  Scenario: Set proc host globally
    Given a fixture app "asset-host-app"
    And a file named "config.rb" with:
      """
      activate :asset_host
      set :asset_host do |asset|
        "http://assets%d.example.com" % (asset.hash % 4)
      end
      """
    And the Server is running
    When I go to "/asset_host.html"
    Then I should see "http://assets"
    When I go to "/stylesheets/asset_host.css"
    Then I should see "http://assets"

  Scenario: Set single host with inline-option
    Given a fixture app "asset-host-app"
    And a file named "config.rb" with:
      """
      activate :asset_host, :host => "http://assets1.example.com"
      """
    And the Server is running
    When I go to "/asset_host.html"
    Then I should see "http://assets1"
    When I go to "/stylesheets/asset_host.css"
    Then I should see "http://assets1"

  Scenario: Set proc host with inline-option
    Given a fixture app "asset-host-app"
    And a file named "config.rb" with:
      """
      activate :asset_host, :host => Proc.new { |asset|
        "http://assets%d.example.com" % (asset.hash % 4)
      }
      """
    And the Server is running
    When I go to "/asset_host.html"
    Then I should see "http://assets"
    When I go to "/stylesheets/asset_host.css"
    Then I should see "http://assets"