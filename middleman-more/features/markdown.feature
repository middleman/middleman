Feature: Markdown support
  In order to test included Maruku support

  Scenario: Rendering html
    Given the Server is running at "markdown-app"
    When I go to "/index.html"
    Then I should see "<p>Hello World</p>"
  
  Scenario: Markdown extensions (Maruku)
    Given the Server is running at "markdown-app"
    When I go to "/smarty_pants.html"
    Then I should see "&"