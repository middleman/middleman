Feature: Built-in macro view helpers
  In order to simplify generating HTML

  Scenario: Using the link_to helper
    Given the Server is running at "test-app"
    When I go to "/padrino_test.html"
    And I should see 'href="test2.com"'
    And I should see 'src="/images/test2.png"'
    Then I should see 'src="/javascripts/test1.js"'
    Then I should see 'href="/stylesheets/test1.css"'