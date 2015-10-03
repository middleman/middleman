Feature: Support mustache templates

  Scenario: Rendering mustache with partial
    Given the Server is running at "mustache-app"
    When I go to "/mustache_master.html"
    Then I should see "Hello, World!"
    Then I should see "Greetings"
    Then I should see "current_page value"
  
  Scenario: Rendering mustache with data
    Given the Server is running at "mustache-app"
    When I go to "/data2.html"
    Then I should see "OneTwo"
