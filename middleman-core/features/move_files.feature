Feature: Move files

  Scenario: Move one path to another
    Given a fixture app "large-build-app"
    And a file named "config.rb" with:
    """
    move_file "/static.html", "/static2.html"
    """
    And the Server is running at "large-build-app"
    When I go to "/static.html"
    Then I should see 'Not Found'
    When I go to "/static2.html"
    Then I should see 'Static, no code!'

  Scenario: Move one path to another with directory indexes
    Given a fixture app "large-build-app"
    And a file named "config.rb" with:
    """
    activate :directory_indexes
    move_file "/static.html", "/static2.html"
    """
    And the Server is running at "large-build-app"
    When I go to "/static.html"
    Then I should see 'Not Found'
    When I go to "/static/index.html"
    Then I should see 'Not Found'
    When I go to "/static2.html"
    Then I should see 'Static, no code!'

  Scenario: Move one path to another with directory indexes (using dest path)
    Given a fixture app "large-build-app"
    And a file named "config.rb" with:
    """
    activate :directory_indexes
    move_file "/static/index.html", "/static2.html"
    """
    And the Server is running at "large-build-app"
    When I go to "/static.html"
    Then I should see 'Not Found'
    When I go to "/static/index.html"
    Then I should see 'Not Found'
    When I go to "/static2.html"
    Then I should see 'Static, no code!'

