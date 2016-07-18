Feature: Sass/SCSS support in Slim
  In order to test support of the Slim sass and scss filters

  Scenario: Sass filter in Slim works
    Given a fixture app "sass-in-slim-app"
    And a file named "config.rb" with:
      """
      activate :directory_indexes
      """
    And a file named "source/sass_filter.html.slim" with:
      """
      sass:
        .sass
          margin: 0
      """
    Given the Server is running at "sass-in-slim-app"
    When I go to "/sass_filter/"
    Then I should see "text/css"
    Then I should see ".sass"
    Then I should see "margin:0"


  Scenario: SCSS filter in Slim works
    Given a fixture app "sass-in-slim-app"
    And a file named "config.rb" with:
      """
      activate :directory_indexes
      """
    And a file named "source/scss_filter.html.slim" with:
      """
      scss:
        .scss {
          margin: 0;
        }
      """
    Given the Server is running at "sass-in-slim-app"
    When I go to "/scss_filter/"
    Then I should see "text/css"
    Then I should see ".scss"
    Then I should see "margin:0"
