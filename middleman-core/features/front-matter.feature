Feature: YAML Front Matter
  In order to specific options and data inline

  Scenario: Rendering html (yaml)
    Given the Server is running at "frontmatter-app"
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

  Scenario: Rendering markdown (template-less) (yaml)
    Given the Server is running at "frontmatter-app"
    When I go to "/front-matter-pandoc.html"
    Then I should see ">This is a document</h1>"
    Then I should see "<p>To be or not to be</p>"
    Then I should see "The meaning of life is 42"
    Then I should not see "..."
    Then I should not see "layout: false"
    Then I should not see "title: Pandoc likes trailing dots..."

  Scenario: Rendering Haml (yaml)
    Given the Server is running at "frontmatter-app"
    When I go to "/front-matter-haml.html"
    Then I should see "<h1>This is the title</h1>"
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

  Scenario: A template should handle YAML with types
    Given the Server is running at "frontmatter-app"
    And the file "source/front-matter-types.html.erb" has the contents
      """
      ---
      date_matter: 2020-01-01
      time_matter: 2020-12-31 13:14:15 +0000
      symbol_matter: :a_symbol
      regexp_matter: !ruby/regexp /a|b/
      ---
      Date: <%= current_page.data.date_matter.strftime('%d %m %Y') %>
      Time: <%= current_page.data.time_matter.strftime('%d %m %Y %H::%M::%S %z') %>
      Symbol: <%= current_page.data.symbol_matter.is_a? Symbol %>
      Regexp: <%= "za" =~ current_page.data.regexp_matter %>
      """
    When I go to "/front-matter-types.html"
    Then I should see "Date: 01 01 2020"
    Then I should see "Time: 31 12 2020 13::14::15 +0000"
    Then I should see "Symbol: true"
    Then I should see "Regexp: 1"

  Scenario: Rendering raw (template-less) (toml)
    Given the Server is running at "frontmatter-app"
    When I go to "/raw-front-matter-toml.html"
    Then I should see "<h1><%= current_page.data.title %></h1>"
    Then I should not see "---"