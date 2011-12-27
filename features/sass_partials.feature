Feature: Sass Partials
  Scenario: The preview server should update stylesheets when Sass partials change
  Given the Server is running at "preview-app"
    And the file "source/stylesheets/_partial.sass" has the contents
      """
      body
        font-size: 14px
      """
    When I go to "/stylesheets/main.css"
    Then I should see "font-size: 14px"
    And the file "source/stylesheets/_partial.sass" has the contents
      """
      body
        font-size: 18px
      """
    When I go to "/stylesheets/main.css"
    Then I should see "font-size: 18px"