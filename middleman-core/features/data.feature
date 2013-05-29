Feature: Local Data API
  In order to abstract content from structure

  Scenario: Rendering html
    Given the Server is running at "basic-data-app"
    When I go to "/data.html"
    Then I should see "One:Two"
    When the file "data/test.yml" has the contents
      """
      -
        title: "Three"
      -
        title: "Four"
      """
    When I go to "/data.html"
    Then I should see "Three:Four"
    When the file "data/test.yml" is removed
    When I go to "/data.html"
    Then I should see "No Test Data"

  Scenario: Rendering json
    Given the Server is running at "basic-data-app"
    When I go to "/data3.html"
    Then I should see "One:Two"
    When the file "data/test2.json" has the contents
      """
      [
        { "title": "Three" },
        { "title": "Four" }
      ]
      """
    When I go to "/data3.html"
    Then I should see "Three:Four"
    When the file "data/test2.json" is removed
    When I go to "/data3.html"
    Then I should see "No Test Data"

  Scenario: Using data in config.rb
    Given the Server is running at "data-app"
    When I go to "/test1.html"
    Then I should see "Welcome"

  Scenario: Using data2 in config.rb
    Given the Server is running at "data-app"
    When I go to "/test2.html"
    Then I should see "Welcome"

  Scenario: Using nested data
    Given the Server is running at "nested-data-app"
    When I go to "/test.html"
    Then I should see "title1:Hello"
    Then I should see "title2:More"
    Then I should see "title3:Stuff"
