Feature: YAML Front Matter
  In order to specific options and data inline

  Scenario: Rendering html
    Given the Server is running at "test-app"
    When I go to "/front-matter.html"
    Then I should see "<h1>This is the title</h1>"