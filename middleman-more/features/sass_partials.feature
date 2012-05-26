Feature: Sass Updates and Partials
  Scenario: The preview server should update stylesheets when Sass changes
    Given the Server is running at "preview-app"
    And the file "source/stylesheets/plain.css.sass" has the contents
      """
      red
        color: red
      """
    When I go to "/stylesheets/plain.css"
    Then I should see "color: red;"
    And the file "source/stylesheets/plain.css.sass" has the contents
      """
      red
        color: blue
      """
    When I go to "/stylesheets/plain.css"
    Then I should see "color: blue;"

  Scenario: The preview server should update stylesheets when Sass partials change
    Given the Server is running at "preview-app"
    And the file "source/stylesheets/main.css.sass" has the contents
      """
      @import partial.sass

      red
        color: red
      """
    And the file "source/stylesheets/_partial.sass" has the contents
      """
      body
        font-size: 14px
      """
    When I go to "/stylesheets/main.css"
    Then I should see "color: red;"
    And I should see "font-size: 14px;"
    And the file "source/stylesheets/main.css.sass" has the contents
      """
      @import partial.sass

      red
        color: blue
      """
    And the file "source/stylesheets/_partial.sass" has the contents
      """
      body
        font-size: 18px
      """
    When I go to "/stylesheets/main.css"
    Then I should see "color: blue;"
    And I should see "font-size: 18px"

  Scenario: Sass partials should work when building
    Given a successfully built app at "preview-app"
    Then the file "build/stylesheets/main.css" should contain "font-size: 18px"
