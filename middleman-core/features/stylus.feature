Feature: Stylus Updates and Partials
  Scenario: The preview server should update stylesheets when Stylus changes
    Given the Server is running at "stylus-preview-app"
    And the file "source/stylesheets/plain.css.styl" has the contents
      """
      red
        color: #f0f0f0
      """
    When I go to "/stylesheets/plain.css"
    Then I should see "color: #f0f0f0;"
    And the file "source/stylesheets/plain.css.styl" has the contents
      """
      red
        color: #0f0f0f
      """
    When I go to "/stylesheets/plain.css"
    Then I should see "color: #0f0f0f;"

  Scenario: The preview server should update stylesheets when Stylus partials change
    Given the Server is running at "stylus-preview-app"
    And the file "source/stylesheets/main.css.styl" has the contents
      """
      @import '_partial'

      red
        color: #f0f0f0
      """
    And the file "source/stylesheets/_partial.styl" has the contents
      """
      body
        font-size: 14px
      """
    When I go to "/stylesheets/main.css"
    Then I should see "color: #f0f0f0;"
    And I should see "font-size: 14px;"
    And the file "source/stylesheets/main.css.styl" has the contents
      """
      @import '_partial'

      red
        color: #0f0f0f
      """
    And the file "source/stylesheets/_partial.styl" has the contents
      """
      body
        font-size: 18px
      """
    When I go to "/stylesheets/main.css"
    Then I should see "color: #0f0f0f;"
    And I should see "font-size: 18px"

  Scenario: Stylus partials should work when building
    Given a successfully built app at "stylus-preview-app"
    Then the file "build/stylesheets/main.css" should contain "font-size: 18px"
