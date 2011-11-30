Feature: Support Rack apps mounted using map

  Scenario: Mounted Rack App at /sinatra
    Given the Server is running at "sinatra-app"
    When I go to "/"
    Then I should see "Hello World (Middleman)"
    When I go to "/sinatra/"
    Then I should see "Hello World (Sinatra)"