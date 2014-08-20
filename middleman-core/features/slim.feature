Feature: Support slim templating language
  In order to offer an alternative to Haml

  Scenario: Rendering Slim
    Given an empty app
    And a file named "config.rb" with:
      """
      """
    And a file named "source/slim.html.slim" with:
      """
      doctype 5
      html lang='en'
        head
          meta charset="utf-8"

        body
          h1 Welcome to Slim
      """
    And the Server is running at "empty_app"
    When I go to "/slim.html"
    Then I should see "<h1>Welcome to Slim</h1>"

  Scenario: Slim Content For
    Given the Server is running at "slim-content-for-app"
    When I go to "/index.html"
    Then I should not see "Content AContent B"
    Then I should see "Content for A:Content A"
    Then I should see "Content for main:Content Main"
    Then I should see "Content for B:Content B"

  Scenario: Rendering Scss in a Slim filter
    Given an empty app
    And a file named "config.rb" with:
      """
      """
    And a file named "source/scss.html.slim" with:
      """
      doctype 5
      html lang='en'
        head
          meta charset="utf-8"
          scss:
            @import "compass";
            @include global-reset;
        body
          h1 Welcome to Slim
      """
    And a file named "source/sass.html.slim" with:
      """
      doctype 5
      html lang='en'
        head
          meta charset="utf-8"
          sass:
            @import "compass"
            +global-reset
        body
          h1 Welcome to Slim
      """
    And a file named "source/error.html.slim" with:
      """
      doctype 5
      html lang='en'
        head
          meta charset="utf-8"
          scss:
            +global-reset
        body
          h1 Welcome to Slim
      """
    And the Server is running at "empty_app"
    When I go to "/scss.html"
    Then I should see "html, body, div"
    When I go to "/sass.html"
    Then I should see "html, body, div"
    When I go to "/error.html"
    Then I should see "Error: Invalid"