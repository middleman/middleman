Feature: Markdown support in Slim
  In order to test support of the Slim markdown filter

  Scenario: Markdown filter in Slim works
    Given a fixture app "markdown-in-slim-app"
    And a file named "config.rb" with:
      """
      set :markdown_engine, :redcarpet
      activate :directory_indexes
      """
    And a file named "source/markdown_filter.html.slim" with:
      """
      markdown:
        # H1

        paragraph
      """
    Given the Server is running
    When I go to "/markdown_filter/"
    Then I should see ">H1</h1>"
    Then I should see "<p>paragraph</p>"


  Scenario: Markdown filter in Slim uses our link_to and image_tag helpers
    Given a fixture app "markdown-in-slim-app"
    And a file named "config.rb" with:
      """
      set :markdown_engine, :redcarpet
      activate :directory_indexes
      """
    And a file named "source/link_and_image.html.slim" with:
      """
      markdown:
        [A link](/link_target.html)

        ![image](blank.gif)
      """
    Given the Server is running
    When I go to "/link_and_image/"
    Then I should see "/link_target/"
    Then I should see 'src="/images/blank.gif"'
