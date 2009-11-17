Feature: generated license
  In order to start a new gem
  A user should be able to
  generate a default license

  Scenario: copyright
    Given a working directory
    And I have configured git sanely
    When I generate a project named 'the-perfect-gem' that is 'zomg, so good'

    Then 'README.rdoc' contains '= the-perfect-gem'
    And 'README.rdoc' mentions copyright belonging to me in the current year
