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

  Scenario: Numeric keys in YAML
    Given the Server is running at "basic-data-app"
    When the file "data/by_year.yml" has the contents
      """
      -
        2018: 1
        2019: 2
      """
    And the file "source/years.html.erb" has the contents
      """
        <%= data.by_year.first[2018] %>:<%= data.by_year.first[2019] %>
      """
    When I go to "/years.html"
    Then I should see "1:2"

  Scenario: Date keys in YAML
    Given the Server is running at "basic-data-app"
    When the file "data/dates.yml" has the contents
      """
      2016-03-25:
        title: "1"
      2018-03-25:
        title: "2"
      """
    And the file "source/years.html.erb" has the contents
      """
        <%= data.dates.values.map(&:title).join(":") %>
      """
    When I go to "/years.html"
    Then I should see "1:2"

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

  Scenario: Using data postscript
    Given the Server is running at "nested-data-app"
    When I go to "/extracontent.html"
    Then I should see "<h1>With Content</h1>"
    Then I should see '<h2 id="header-2">Header 2</h2>'
    Then I should see "<p>Paragraph 1</p>"

  Scenario: Rendering toml
    Given the Server is running at "basic-data-app"
    When I go to "/data4.html"
    Then I should see "One:Two"
    When the file "data/test3.toml" has the contents
      """
      [titles]

      [titles.first]
        title = "Three"

      [titles.second]
        title = "Four"
      """
    When I go to "/data4.html"
    Then I should see "Three:Four"
    When the file "data/test3.toml" is removed
    When I go to "/data4.html"
    Then I should see "No Test Data"