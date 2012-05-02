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

  Scenario: Redcarpet 2 extensions
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      set :markdown_engine, :redcarpet
      set :markdown, :no_intra_emphasis => true,
                     :tables => true,
                     :fenced_code_blocks => true,
                     :autolink => true,
                     :strikethrough => true,
                     :lax_html_blocks => true,
                     :space_after_headers => true,
                     :superscript => true#, :smartypants => true
                     
      """
    Given the Server is running at "markdown-app"
    # When I go to "/smarty_pants.html"
    # Then I should see "&#8220;"
    When I go to "/no_intra_emphasis.html"
    Then I should not see "<em>"
    When I go to "/tables.html"
    Then I should see "<table>"
    When I go to "/fenced_code_blocks.html"
    Then I should see "<code>"
    When I go to "/autolink.html"
    Then I should see "<a href"
    When I go to "/strikethrough.html"
    Then I should see "<del>"
    When I go to "/space_after_headers.html"
    Then I should not see "<h1>"
    When I go to "/superscript.html"
    Then I should see "<sup>"
    