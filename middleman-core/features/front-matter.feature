Feature: YAML Front Matter
  In order to specific options and data inline

  Scenario: Rendering html (yaml)
    Given the Server is running at "frontmatter-app"
    When I go to "/front-matter-auto.html"
    Then I should see "<h1>This is the title</h1>"
    Then I should not see "---"
    When I go to "/front-matter-2.php"
    Then I should see "<h1>This is the title</h1>"
    Then I should see "<?php"
    Then I should not see "---"

  Scenario: Rendering raw (template-less) (yaml)
    Given the Server is running at "frontmatter-app"
    When I go to "/raw-front-matter.html"
    Then I should see "<h1><%= current_page.data.title %></h1>"
    Then I should not see "---"
    When I go to "/raw-front-matter.php"
    Then I should see '<?php echo "sup"; ?>'
    Then I should see "<?php"
    Then I should not see "---"

  Scenario: YAML not on first line, no encoding
    Given the Server is running at "frontmatter-app"
    When I go to "/front-matter-line-2.html"
    Then I should see "<h1></h1>"
    Then I should see "---"
    
  Scenario: YAML not on first line, with encoding
    Given the Server is running at "frontmatter-app"
    When I go to "/front-matter-encoding.html"
    Then I should see "<h1>This is the title</h1>"
    Then I should not see "---"
    
  Scenario: Rendering html (json)
    Given the Server is running at "frontmatter-app"
    When I go to "/json-front-matter-auto.html"
    Then I should see "<h1>This is the title</h1>"
    Then I should not see ";;;"
    When I go to "/json-front-matter.html"
    Then I should see "<h1>This is the title</h1>"
    Then I should not see ";;;"
    When I go to "/json-front-matter-2.php"
    Then I should see "<h1>This is the title</h1>"
    Then I should see "<?php"
    Then I should not see ";;;"

  Scenario: JSON not on first line, no encoding
    Given the Server is running at "frontmatter-app"
    When I go to "/json-front-matter-line-2.html"
    Then I should see "<h1></h1>"
    Then I should see ";;;"
    
  Scenario: JSON not on first line, with encoding
    Given the Server is running at "frontmatter-app"
    When I go to "/json-front-matter-encoding.html"
    Then I should see "<h1>This is the title</h1>"
    Then I should not see ";;;"

  Scenario: A template changes frontmatter during preview
    Given the Server is running at "frontmatter-app"
    And the file "source/front-matter-change.html.erb" has the contents
      """
      ---
      title: Hello World
      layout: false
      ---
      <%= current_page.data.title %>
      """
    When I go to "/front-matter-change.html"
    Then I should see "Hello World"
    And the file "source/front-matter-change.html.erb" has the contents
      """
      ---
      title: Hola Mundo
      layout: false
      ---
      <%= current_page.data.title %>
      """
    When I go to "/front-matter-change.html"
    Then I should see "Hola Mundo"

  Scenario: A template should handle an empty YAML feed
    Given the Server is running at "frontmatter-app"
    And the file "source/front-matter-change.html.erb" has the contents
    """
    ---
    ---
    Hello World
    """
    When I go to "/front-matter-change.html"
    Then I should see "Hello World"
