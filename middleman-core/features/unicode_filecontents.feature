Feature: Unicode filecontents
  In order to support non-ASCII characters in file contents

  Scenario: Rebuild with files containing unicode characters in their name
    Given a fixture app "clean-app"
    And a file named "source/index.html.erb" with:
      """
      你好
      """
    And a successfully built app at "clean-app"
    And a modification time for a file named "build/index.html"
    And a successfully built app at "clean-app"
    Then the file "build/index.html" should not have been updated
