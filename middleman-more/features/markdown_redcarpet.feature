@nojava
Feature: Markdown support
  In order to test included Maruku support

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
                     :with_toc_data => true,
                     :superscript => true,
                     :smartypants => true,
                     :hard_wrap => true
                     
      """
    Given the Server is running at "markdown-app"
    When I go to "/smarty_pants.html"
    Then I should see "&ldquo;"
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
    When I go to "/with_toc_data.html"
    Then I should see "toc_0"
    When I go to "/hard_wrap.html"
    Then I should see "br"