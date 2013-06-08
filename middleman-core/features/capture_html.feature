@wip

Feature: Support capture_html and yield_content helpers

  Scenario: content_for works as expected in erb
    Given the Server is running at "capture-html-app"
    When I go to "/capture_html_erb.html"
    Then I should see "In Layout: <h1>I am the yielded content erb</h1>"
    
  Scenario: content_for works as expected in haml
    Given the Server is running at "capture-html-app"
    When I go to "/capture_html_haml.html"
    Then I should see "In Layout: <h1>I am the yielded content haml</h1>"
    
  Scenario: content_for works as expected in slim
    Given the Server is running at "capture-html-app"
    When I go to "/capture_html_slim.html"
    Then I should see "In Layout: <h1>I am the yielded content slim</h1>"