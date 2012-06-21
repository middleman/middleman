@encoding @travishatesme @wip

Feature: Unicode filenames
  In order to support non-ASCII characters in filenames

  Scenario: Build with files containing unicode characters in their name
    Given a fixture app "empty-app"
    And a file named "config.rb" with:
      """
      """
    And a file named "source/snowmen-rule-☃.html" with:
      """
      Snowman!
      <div style="text-align:center; font-size:4000%;">
        ☃
      </div>
      """
    And a successfully built app at "empty-app"
    When I cd to "build"
    Then the file "snowmen-rule-☃.html" should contain "☃"

  Scenario: Preview with files containing unicode characters in their name
    Given a fixture app "empty-app"
    And a file named "config.rb" with:
      """
      """
    And a file named "source/snowmen-rule-☃.html" with:
      """
      Snowman!
      <div style="text-align:center; font-size:4000%;">
        ☃
      </div>
      """
    And the Server is running
    When I go to "/snowmen-rule-☃.html"
    Then I should see "Snowman!"