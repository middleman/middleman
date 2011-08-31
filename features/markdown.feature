Feature: Markdown support
  In order to test included Maruku support

  Scenario: Rendering html
    Given the Server is running at "test-app"
    When I go to "/markdown.html"
    Then I should see "<p>Hello World</p>"