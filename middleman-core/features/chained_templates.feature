Feature: Templates should be chainable
  In order to insert variables and data in "static" engines

  Scenario: Data in Erb in Markdown
    Given the Server is running at "chained-app"
    When I go to "/index.html"
    Then I should see "Title</h1>"
    And I should see "Subtitle</h2>"
    And I should see "Sup</h3>"
    
  Scenario: Build chained template
    Given a successfully built app at "chained-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html                                    |

    And the file "index.html" should contain "Title</h1>"
    And the file "index.html" should contain "Subtitle</h2>"
    And the file "index.html" should contain "Sup</h3>"

  Scenario: Partials are parsed by multiple template engines: Outer template has .erb and inner .md.erb
    Given a fixture app "partial-chained_templates-app"
    And a template named "my_template.html.erb" with:
    """
    <h1>My Template</h1>

    <%= partial 'my_partial' %>
    """
    And a template named "my_partial.html.md.erb" with:
    """
    ## My Partial
    
    <%= 'hello world' %>
    """
    And the Server is running
    When I go to "/my_template.html"
    Then I should see:
    """
    <h1>My Template</h1>
    """
    Then I should see:
    """
    <h2 id="my-partial">My Partial</h2>
    """
    Then I should see:
    """
    <p>hello world</p>
    """

  Scenario: Partials are parsed by multiple template engines: Outer template has .md.erb and inner .md.erb
    Given a fixture app "partial-chained_templates-app"
    And a template named "my_template.html.md.erb" with:
    """
    # My Template

    <%= partial 'my_partial' %>
    """
    And a template named "my_partial.html.md.erb" with:
    """
    ## My Partial
    
    <%= 'hello world' %>
    """
    And the Server is running
    When I go to "/my_template.html"
    Then I should see:
    """
    <h1 id="my-template">My Template</h1>
    """
    Then I should see:
    """
    <h2 id="my-partial">My Partial</h2>
    """
    Then I should see:
    """
    <p>hello world</p>
    """

  Scenario: Partials are parsed by multiple template engines: Outer template has .md.erb, and inner .erb
    Given a fixture app "partial-chained_templates-app"
    And a template named "my_template.html.md.erb" with:
    """
    # My Template

    <%= partial 'my_partial' %>
    """
    And a template named "my_partial.html.erb" with:
    """
    <h2>My Partial</h2>
    
    <%= 'hello world' %>
    """
    And the Server is running
    When I go to "/my_template.html"
    Then I should see:
    """
    <h1 id="my-template">My Template</h1>
    """
    Then I should see:
    """
    <h2>My Partial</h2>
    """
    Then I should see:
    """
    <p>hello world</p>
    """
