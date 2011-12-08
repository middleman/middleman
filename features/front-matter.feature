Feature: YAML Front Matter
  In order to specific options and data inline

  Scenario: Rendering html
    Given the Server is running at "test-app"
    When I go to "/front-matter.html"
    Then I should see "<h1>This is the title</h1>"
    Then I should not see "---"

  Scenario: A template changes frontmatter during preview
    Given the Server is running at "test-app"
    And the file "source/front-matter-change.html.erb" has the contents
      """
      ---
      title: Hello World
      layout: false
      ---
      <%= data.page.title %>
      """
    When I go to "/front-matter-change.html"
    Then I should see "Hello World"
    And the file "source/front-matter-change.html.erb" has the contents
      """
      ---
      title: Hola Mundo
      layout: false
      ---
      <%= data.page.title %>
      """
    When I go to "/front-matter-change.html"
    Then I should see "Hola Mundo"