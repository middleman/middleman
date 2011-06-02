Feature: Support slim templating language
  In order to offer an alternative to Haml

  Scenario: Rendering Slim
    Given the Server is running
    When I go to "/slim.html"
    Then I should see "<h1>Welcome to Slim</h1>"