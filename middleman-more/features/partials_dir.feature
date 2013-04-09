Feature: Partials dir
  Scenario: Find partials in a custom partials dir
    Given a fixture app "partials-dir-app"
    And a file named "config.rb" with:
    """
    set :partials_dir, 'partials'
    """
    And the Server is running
    When I go to "/index.html"
    Then I should see "contents of the partial"

  Scenario: Find partials in a nested custom partials dir
    Given a fixture app "partials-dir-app"
    And a file named "config.rb" with:
    """
    set :partials_dir, 'nested/partials'
    """
    And the Server is running
    When I go to "/index.html"
    Then I should see "contents of the nested partial"

  Scenario: Find partials in the default partials dir
    Given a fixture app "default-partials-dir-app"
    And a file named "config.rb" with:
    """
    """
    And the Server is running
    When I go to "/index.html"
    Then I should see "contents of the partial"

