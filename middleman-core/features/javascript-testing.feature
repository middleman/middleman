Feature: Test a site with javascript included

  As a software developer
  I want to develop a site using javascript
  I would like to have a server step rendering javascript correctly in order to test it

  @javascript
  Scenario: Existing app with javascript
    Given the Server is running at "javascript-app"
    When I go to "/index.html"
    Then I should see:
    """
    Local Hour
    """
    And I should see:
    """
    Local Minutes
    """
