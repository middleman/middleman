@nojava
Feature: Markdown (Redcarpet) support
  In order to test included Redcarpet support

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
                     :space_after_headers => true,
                     :superscript => true,
                     :lax_spacing => true

      """
    Given the Server is running at "markdown-app"
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
    When I go to "/lax_spacing.html"
    Then I should see "<p>hello</p>"
    When I go to "/mailto.html"
    Then I should see '<h1>✉ <a href="mailto:mail@mail.com">Mail</a></h1>'

  Scenario: Redcarpet 3 extensions
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      set :markdown_engine, :redcarpet
      set :markdown, :underline => true,
                     :highlight => true,
                     :disable_indented_code_blocks => true
      """
    Given the Server is running at "markdown-app"
    When I go to "/underline.html"
    Then I should see "<u>underlined</u>"
    When I go to "/highlighted.html"
    Then I should see "<mark>highlighted</mark>"
    When I go to "/indented_code_blocks.html"
    Then I should not see "<code>"

  Scenario: Redcarpet smartypants extension
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      set :markdown_engine, :redcarpet
      set :markdown, :smartypants => true
      """
    Given the Server is running at "markdown-app"
    When I go to "/smarty_pants.html"
    Then I should see "&ldquo;"

  Scenario: Redcarpet::Render::HTML options
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      set :markdown_engine, :redcarpet
      set :markdown, :filter_html => true,
                     :no_images => true,
                     :no_links => true,
                     :with_toc_data => true,
                     :hard_wrap => true,
                     :safe_links_only => true,
                     :prettify => true

      """
    Given the Server is running at "markdown-app"
    When I go to "/filter_html.html"
    Then I should not see "<em>"
    When I go to "/img.html"
    Then I should see "![dust mite](http://dust.mite/image.png)"
    And I should not see "<img"
    When I go to "/with_toc_data.html"
    Then I should see 'id="first-header"'
    And I should see 'id="second-header"'
    When I go to "/hard_wrap.html"
    Then I should see "br"
    When I go to "/link.html"
    Then I should see "[This link](http://example.net/) links"
    And I should not see "<a"
    When I go to "/safe_links.html"
    Then I should see "[IRC](irc://chat.freenode.org/#freenode)"
    When I go to "/prettify.html"
    Then I should see '<code class="prettyprint">'

  Scenario: Redcarpet link_attributes option
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      set :markdown_engine, :redcarpet
      set :markdown, :link_attributes => { :target => "_blank" }
      """
    And a file named "source/link.html.markdown" with:
      """
      [A link](/foo.html)
      """
    Given the Server is running at "markdown-app"
    When I go to "/link.html"
    Then I should see 'target="_blank"'

  Scenario: Redcarpet xhtml option
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      set :markdown_engine, :redcarpet
      set :markdown, :xhtml => true,
                     :hard_wrap => true
      """
    Given the Server is running at "markdown-app"
    When I go to "/hard_wrap.html"
    Then I should see "<br/>"

  Scenario: Redcarpet per-page frontmatter options
    Given a fixture app "markdown-frontmatter-options-app"
    And a file named "config.rb" with:
      """
      set :markdown_engine, :redcarpet
      set :markdown, :smartypants => true
      """
    Given the Server is running at "markdown-frontmatter-options-app"
    When I go to "/smarty_pants-default.html"
    Then I should see "&ldquo;"
    When I go to "/smarty_pants-on.html"
    Then I should see "&ldquo;"
    When I go to "/smarty_pants-off.html"
    Then I should not see "&ldquo;"
    When I go to "/tables-default.html"
    Then I should not see "<table>"
    When I go to "/tables-on.html"
    Then I should see "<table>"
    When I go to "/tables-off.html"
    Then I should not see "<table>"

  Scenario: Redcarpet uses our link_to and image_tag helpers
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      set :markdown_engine, :redcarpet
      activate :automatic_image_sizes
      activate :directory_indexes
      """
    And a file named "source/link_and_image.html.markdown" with:
      """
      [A link](/smarty_pants.html)

      ![image](blank.gif)
      """
    Given the Server is running at "markdown-app"
    When I go to "/link_and_image/"
    Then I should see "/smarty_pants/"
    Then I should see 'width="1"'
    And I should see 'height="1"'
    And I should see 'src="/images/blank.gif"'
