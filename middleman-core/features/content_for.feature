Feature: Support content_for and yield_content helpers

  Scenario: content_for works as expected in erb
    Given the Server is running at "content-for-app"
    When I go to "/content_for_erb.html"
    Then I should see "In Layout: I am the yielded content erb"