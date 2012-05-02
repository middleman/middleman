Feature: Markdown support
  In order to test included Maruku support

  Scenario: Rendering html
    Given the Server is running at "markdown-app"
    When I go to "/index.html"
    Then I should see "<p>Hello World</p>"
  
  Scenario: Markdown extensions (Maruku)
    Given the Server is running at "markdown-app"
    When I go to "/smarty_pants.html"
    Then I should see "&#8220;"
    When I go to "/no_intra_emphasis.html"
    Then I should not see "<em>"
    When I go to "/tables.html"
    Then I should see "<table>"
    When I go to "/space_after_headers.html"
    Then I should not see "<h1>"