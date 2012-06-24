Feature: Built-in macro view helpers
  In order to simplify generating HTML

  Scenario: Using the padrino helpers
    Given the Server is running at "padrino-helpers-app"
    When I go to "/former_padrino_test.html"
    And I should see 'href="test2.com"'
    And I should see 'src="/images/test2.png"'
    And I should see 'src="/images/100px.png"'
    And I should see 'src="/javascripts/test1.js"'
    And I should see 'href="/stylesheets/test1.css"'
    And I should see '1 KB'

  Scenario: Setting http_prefix
    Given a fixture app "padrino-helpers-app"
    And a file named "config.rb" with:
    """
    set :http_prefix, "/foo"
    """
    And the Server is running at "padrino-helpers-app"
    When I go to "/former_padrino_test.html"
    And I should see 'src="/foo/images/test2.png"'
    And I should see 'src="/foo/images/100px.png"'
    And I should see 'src="/foo/javascripts/test1.js"'
    And I should see 'href="/foo/stylesheets/test1.css"'

                