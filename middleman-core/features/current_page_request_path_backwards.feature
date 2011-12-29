Feature: Support old request.path object used by many extensions
  
  Scenario: Viewing the root path
    Given the Server is running at "current-page-app"
    When I go to "/request-path.html"
    Then I should see "true"