Feature: Support content_for and yield_content helpers

  Scenario: content_for works as expected in erb
    Given the Server is running at "content-for-app"
    When I go to "/content_for_erb.html"
    Then I should see "In Layout: I am the yielded content erb <s>with html tags</s>"
    
  Scenario: content_for works as expected in haml
    Given the Server is running at "content-for-app"
    When I go to "/content_for_haml.html"
    Then I should see "In Layout: I am the yielded content haml <s>with html tags</s>"
    
  Scenario: content_for works as expected in slim
    Given the Server is running at "content-for-app"
    When I go to "/content_for_slim.html"
    Then I should see "In Layout: I am the yielded content slim <s>with html tags</s>"