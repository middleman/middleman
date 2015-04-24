Feature: Markdown support in Haml (Kramdown)
  In order to test support of the Haml markdown filter

  Scenario: Markdown filter in Haml works (with Kramdown)
    Given a fixture app "markdown-in-haml-app"
    And a file named "config.rb" with:
      """
      set :markdown_engine, :kramdown
      activate :directory_indexes
      """
    And a file named "source/markdown_filter.html.haml" with:
      """
      :markdown
        # H1

        paragraph
      """
    Given the Server is running at "markdown-in-haml-app"
    When I go to "/markdown_filter/"
    Then I should see ">H1</h1>"
    Then I should see "<p>paragraph</p>"


  Scenario: Markdown filter in Haml uses our link_to and image_tag helpers (with Kramdown)
    Given a fixture app "markdown-in-haml-app"
    And a file named "config.rb" with:
      """
      set :markdown_engine, :kramdown
      activate :directory_indexes
      """
    And a file named "source/link_and_image.html.haml" with:
      """
      :markdown
        [A link](/link_target.html)

        ![image](blank.gif){: srcset="image_2x.jpg 2x"}
      """
    Given the Server is running at "markdown-in-haml-app"
    When I go to "/link_and_image/"
    Then I should see "/link_target/"
    Then I should see "/images/image_2x.jpg 2x"
    Then I should see 'src="/images/blank.gif"'
