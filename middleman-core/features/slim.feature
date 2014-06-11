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
