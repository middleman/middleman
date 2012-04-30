Feature: Unicode filenames
  In order to support non-ASCII characters in filenames

  Scenario: Build with files containing unicode characters in their name
    Given a successfully built app at "unicode-filenames-app"
    When I cd to "build"
    Then the file "snowmen-rule-☃.html" should contain "☃"

  Scenario: Preview with files containing unicode characters in their name
    Given the Server is running at "unicode-filenames-app"
    When I go to "/snowmen-rule-☃.html"
    # There seem to be encoding issues w/ the test framework so we can't check the content
    Then I should see "Snowman!"
    