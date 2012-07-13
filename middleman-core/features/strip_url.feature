Feature: Strip the index_file from urls

  Scenario: Default behaviour, strip with trailing slash
    Given the Server is running at "strip-url-app"
    When I go to "/"
    Then I should see "URL: '/'"
    When I go to "/index.html"
    Then I should see "URL: '/'"
    When I go to "/other.html"
    Then I should see "URL: '/other.html'"
    When I go to "/subdir/index.html"
    Then I should see "URL: '/subdir/'"

  Scenario: Trailing slash off
    Given a fixture app "strip-url-app"
    And a file named "config.rb" with:
       """
       set :trailing_slash, false
       """
    And the Server is running
    When I go to "/"
    Then I should see "URL: '/'"
    When I go to "/other.html"
    Then I should see "URL: '/other.html'"
    When I go to "/subdir/index.html"
    Then I should see "URL: '/subdir'"

  Scenario: Strip index off
    Given a fixture app "strip-url-app"
    And a file named "config.rb" with:
       """
       set :strip_index_file, false
       """
    And the Server is running
    When I go to "/"
    Then I should see "URL: '/index.html'"
    When I go to "/other.html"
    Then I should see "URL: '/other.html'"
    When I go to "/subdir/index.html"
    Then I should see "URL: '/subdir/index.html'"
