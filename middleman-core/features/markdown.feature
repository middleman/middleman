Feature: Markdown support
  In order to test included Maruku support

  Scenario: Rendering html
    Given the Server is running at "markdown-app"
    When I go to "/index.html"
    Then I should see "<p>Hello World</p>"

  @encoding
  Scenario: Markdown extensions (Maruku)
    Given the Server is running at "markdown-app"
    When I go to "/smarty_pants.html"
    Then I should see "“Hello”"

  Scenario: Links with block syntax in ERB layout (erb)
    Given the Server is running at "more-markdown-app"
    When I go to "/with_layout_erb.html"
    Then I should see '<a href="layout_block_link.html">'
  
  Scenario: Links with block syntax in ERB layout and markdown
    Given the Server is running at "more-markdown-app"
    When I go to "/with_layout.html"
    Then I should see '<a href="layout_block_link.html">'
