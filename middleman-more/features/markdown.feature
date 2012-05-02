Feature: Markdown support
  In order to test included Maruku support

  Scenario: Rendering html
    Given the Server is running at "markdown-app"
    When I go to "/index.html"
    Then I should see "<p>Hello World</p>"
  
  Scenario: Redcarpet 2 extensions
    Given the Server is running at "markdown-app"
    When I go to "/smarty_pants.html"
    Then I should see "&#8220;"
    When I go to "/no_intra_emphasis.html"
    Then I should not see "<em>"
    When I go to "/tables.html"
    Then I should see "<table>"
    # Maruku doesn't support fenced code blocks :-(
    #When I go to "/fenced_code_blocks.html"
    #Then I should see "<code>"
    # or autolink
    #When I go to "/autolink.html"
    #Then I should see "<a href"
    # or del
    #When I go to "/strikethrough.html"
    #Then I should see "<del>"
    When I go to "/space_after_headers.html"
    Then I should not see "<h1>"
    # or superscript
    #When I go to "/superscript.html"
    #Then I should see "<sup>"
    