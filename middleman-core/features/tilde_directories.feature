@encoding

Feature: Tilde directories
  In order to support ~ characters in directories

  Scenario: Build directories with containing ~ characters in their name
    Given a fixture app "empty-app"
    And a file named "source/~notexistinguser/index.html" with:
    """
    It works!
    """
    And the Server is running
    When I go to "/~notexistinguser/index.html"
    Then I should see "It works!"
