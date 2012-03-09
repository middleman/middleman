Feature: Built-in macro view helpers
  In order to simplify generating HTML

  Scenario: Using the padrino helpers
    Given the Server is running at "padrino-helpers-app"
    When I go to "/former_padrino_test.html"
    And I should see 'href="test2.com"'
    And I should see 'src="/images/test2.png"'
    And I should see 'src="/javascripts/test1.js"'
    And I should see 'href="/stylesheets/test1.css"'
    And I should see '1 KB'
                