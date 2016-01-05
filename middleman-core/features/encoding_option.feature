# encoding: iso-8859-1
Feature: encoding option

  Scenario: No encoding set
    Given a fixture app "clean-app"
    Given the Server is running at "clean-app"

    When I go to "/index.html"
    Then the "Content-Type" header should contain "text/html"
    Then the "Content-Type" header should contain "charset=utf-8"

  Scenario: Custom encoding set
    Given a fixture app "i-8859-1-app"
    And a file named "config.rb" with:
      """
      set :encoding, "ISO-8859-1"
      """
    Given the Server is running at "i-8859-1-app"

    When I go to "/index.html"
    Then the "Content-Type" header should contain "text/html"
    Then the "Content-Type" header should contain "charset=iso-8859-1"
    Then I should see "äöü"
