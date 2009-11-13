Feature: HTML formatter
  In order to make it easy to read Cucumber results
  there should be a HTML formatter with an awesome CSS
  
  Scenario: Everything in examples/self_test
    When I run cucumber -q --format html --out tmp/a.html features
    Then "examples/self_test/tmp/a.html" should have the same contents as "features/html_formatter/a.html"
