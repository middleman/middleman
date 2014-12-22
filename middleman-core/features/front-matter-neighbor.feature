Feature: Neighboring YAML Front Matter

  Scenario: Rendering html (yaml)
    Given the Server is running at "frontmatter-neighbor-app"
    When I go to "/front-matter-auto.html"
    Then I should see "<h1>This is the title</h1>"
    Then I should not see "---"
    When I go to "/front-matter-auto.erb.frontmatter"
    Then I should see "File Not Found"
    When I go to "/front-matter-2.php"
    Then I should see "<h1>This is the title</h1>"
    Then I should see "<?php"
    Then I should not see "---"
    When I go to "/front-matter-2.php.erb.frontmatter"
    Then I should see "File Not Found"

  Scenario: Rendering raw (template-less) (yaml)
    Given the Server is running at "frontmatter-neighbor-app"
    When I go to "/raw-front-matter.html"
    Then I should see "<h1><%= current_page.data.title %></h1>"
    Then I should not see "---"
    When I go to "/raw-front-matter.html.frontmatter"
    Then I should see "File Not Found"
    When I go to "/raw-front-matter.php"
    Then I should see '<?php echo "sup"; ?>'
    Then I should see "<?php"
    Then I should not see "---"
    When I go to "/raw-front-matter.php.frontmatter"
    Then I should see "File Not Found"
    
  Scenario: YAML not on first line, with encoding
    Given the Server is running at "frontmatter-neighbor-app"
    When I go to "/front-matter-encoding.html"
    Then I should see "<h1>This is the title</h1>"
    Then I should not see "---"
    When I go to "/front-matter-encoding.html.erb.frontmatter"
    Then I should see "File Not Found"
    
  Scenario: Rendering html (json)
    Given the Server is running at "frontmatter-neighbor-app"
    When I go to "/json-front-matter-auto.html"
    Then I should see "<h1>This is the title</h1>"
    Then I should not see ";;;"
    When I go to "/json-front-matter-auto.erb.frontmatter"
    Then I should see "File Not Found"
    When I go to "/json-front-matter.html"
    Then I should see "<h1>This is the title</h1>"
    Then I should not see ";;;"
    When I go to "/json-front-matter.html.erb.frontmatter"
    Then I should see "File Not Found"
    When I go to "/json-front-matter-2.php"
    Then I should see "<h1>This is the title</h1>"
    Then I should see "<?php"
    Then I should not see ";;;"
    When I go to "/json-front-matter-2.php.erb.frontmatter"
    Then I should see "File Not Found"

  Scenario: A template changes frontmatter during preview
    Given the Server is running at "frontmatter-neighbor-app"
    And the file "source/front-matter-change.html.erb" has the contents
      """
      <%= current_page.data.title %>
      """
    And the file "source/front-matter-change.html.erb.frontmatter" has the contents
      """
      ---
      title: Hello World
      layout: false
      ---
      """
    When I go to "/front-matter-change.html"
    Then I should see "Hello World"
    And the file "source/front-matter-change.html.erb.frontmatter" has the contents
      """
      ---
      title: Hola Mundo
      layout: false
      ---
      """
    When I go to "/front-matter-change.html"
    Then I should see "Hola Mundo"
    When I go to "/front-matter-change.html.erb.frontmatter"
    Then I should see "File Not Found"

  Scenario: A template should handle an empty YAML feed
    Given the Server is running at "frontmatter-neighbor-app"
    And the file "source/front-matter-change.html.erb.frontmatter" has the contents
    """
    ---
    ---
    """
    When I go to "/front-matter-change.html"
    Then I should not see "Hello World"
    Then I should not see "Hola Mundo"
    When I go to "/front-matter-change.html.erb.frontmatter"
    Then I should see "File Not Found"

  Scenario: Setting layout, ignoring, and disabling directory indexes through frontmatter (build)
    Given a successfully built app at "frontmatter-settings-neighbor-app"
    Then the following files should exist:
      | build/proxied.html  |
    And the file "build/alternate_layout.html" should contain "Alternate layout"
    And the following files should not exist:
      | build/ignored.html  |
      | build/alternate_layout.html.erb.frontmatter  |
      | build/ignored.html.erb.frontmatter  |
      | build/override_layout.html.erb.frontmatter  |
      | build/page_mentioned.html.erb.frontmatter  |

  Scenario: Setting layout, ignoring, and disabling directory indexes through frontmatter (preview)
    Given the Server is running at "frontmatter-settings-neighbor-app"
    When I go to "/alternate_layout.html"
    Then I should not see "File Not Found"
    And I should see "Alternate layout"
    When I go to "/alternate_layout.html.erb.frontmatter"
    Then I should see "File Not Found"
    When I go to "/ignored.html"
    Then I should see "File Not Found"
    When I go to "/ignored.html.erb.frontmatter"
    Then I should see "File Not Found"
    When I go to "/ignored/index.html"
    Then I should see "File Not Found"

  Scenario: Changing frontmatter in preview server
    Given the Server is running at "frontmatter-settings-neighbor-app"
    When I go to "/ignored.html"
    Then I should see "File Not Found"
    And the file "source/ignored.html.erb.frontmatter" has the contents
      """
      ---
      ignored: false
      ---
      """
    When I go to "/ignored.html"
    Then I should see "This file ignores itself! But it can still be proxied."
    When I go to "/ignored.html.erb.frontmatter"
    Then I should see "File Not Found"

  Scenario: Overriding layout through frontmatter
    Given the Server is running at "frontmatter-settings-neighbor-app"
    When I go to "/override_layout.html"
    Then I should see "Layout in use: Override"
    When I go to "/override_layout.html.erb.frontmatter"
    Then I should see "File Not Found"

  Scenario: Setting layout through frontmatter even if page is mentioned in config
    Given the Server is running at "frontmatter-settings-neighbor-app"
    When I go to "/page_mentioned.html"
    Then I should see "Layout in use: Override"
    When I go to "/page_mentioned.html.erb.frontmatter"
    Then I should see "File Not Found"

  Scenario: Neighbor frontmatter for destination of proxy resources
    Given the Server is running at "frontmatter-settings-neighbor-app"
    And the file "source/proxied_with_frontmatter.html.frontmatter" has the contents
      """
      ---
      title: Proxied title
      ---
      """
    And the file "source/ignored.html.erb" has the contents
      """
      ---
      ignored: true
      ---

      <%= current_resource.data.title %>
      """
    When I go to "/proxied_with_frontmatter.html"
    Then I should see "Proxied title"
