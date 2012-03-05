Feature: GZIP assets during build

  Scenario: Built assets should be gzipped
    Given a successfully built app at "gzip-app"
    Then the following files should exist:
      | build/javascripts/test.js.gz |
      | build/stylesheets/test.css.gz |
      | build/index.html.gz |
      | build/javascripts/test.js |
      | build/stylesheets/test.css |
      | build/index.html |
    When I run `file build/javascripts/test.js.gz`
    Then the output should contain "gzip"

  Scenario: Preview server doesn't change
    Given the Server is running at "gzip-app"
    When I go to "/javascripts/test.js"
    Then I should see "test_function"
    When I go to "/stylesheets/test.css"
    Then I should see "test_selector"
   