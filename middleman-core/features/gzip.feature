Feature: GZIP assets during build

  Scenario: Built assets should be gzipped
    Given a successfully built app at "gzip-app"
    Then the following files should exist:
      | build/index.html |
      | build/index.html.gz |
      | build/javascripts/test.js |
      | build/javascripts/test.js.gz |
      | build/stylesheets/test.css |
      | build/stylesheets/test.css.gz |
    And the file "build/javascripts/test.js.gz" should be gzipped

  Scenario: Preview server doesn't change
    Given the Server is running at "gzip-app"
    When I go to "/javascripts/test.js"
    Then I should see "test_function"
    When I go to "/stylesheets/test.css"
    Then I should see "test_selector"

  Scenario: Only specified extensions should be gzipped
    Given a fixture app "gzip-app"
    And a file named "config.rb" with:
      """
      activate :gzip, exts: %w(.js .html .htm)
      """
    And a successfully built app at "gzip-app"
    Then the following files should exist:
      | build/index.html |
      | build/index.html.gz |
      | build/javascripts/test.js |
      | build/javascripts/test.js.gz |
      | build/stylesheets/test.css |
    And the following files should not exist:
      | build/stylesheets/test.css.gz |

  Scenario: Gzipped files are not produced for ignored paths
    Given a fixture app "gzip-app"
    And a file named "config.rb" with:
      """
      activate :gzip, ignore: ['index.html', %r(javascripts/.*)]
      """
    And a successfully built app at "gzip-app"
    Then the following files should exist:
      | build/index.html |
      | build/javascripts/test.js |
      | build/stylesheets/test.css |
      | build/stylesheets/test.css.gz |
    And the following files should not exist:
      | build/index.html.gz |
      | build/javascripts/test.js.gz |
