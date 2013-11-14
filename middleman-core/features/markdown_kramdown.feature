Feature: Markdown (Kramdown) support
  In order to test included Kramdown support

  Scenario: Kramdown smartypants extension
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      set :markdown_engine, :kramdown
      set :markdown, :smartypants => true
      """
    Given the Server is running at "markdown-app"
    When I go to "/smarty_pants.html"
    Then I should see "“Hello”"

  Scenario: Kramdown uses our link_to and image_tag helpers
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      set :markdown_engine, :kramdown
      activate :automatic_image_sizes
      activate :directory_indexes
      """
    And a file named "source/link_and_image.html.markdown" with:
      """
      [A link](/smarty_pants.html)

      ![image](blank.gif)

      [mail@mail.com](mailto:mail@mail.com)
      """
    Given the Server is running at "markdown-app"
    When I go to "/link_and_image/"
    Then I should see "/smarty_pants/"
    Then I should see 'width="1"'
    And I should see 'height="1"'
    And I should see 'src="/images/blank.gif"'
    And I should see 'src="/images/blank.gif"'
    And I should see "&#109;&#097;&#105;&#108;&#064;&#109;&#097;&#105;&#108;&#046;&#099;&#111;&#109;"
