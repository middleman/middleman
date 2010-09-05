Feature: Minify Javascript
  In order reduce bytes sent to client and appease YSlow
  
  Scenario: Rendering inline js with the feature disabled
    Given "minify_javascript" feature is "disabled"
    When I go to "/inline-js.html"
    Then I should see "10" lines
  
  Scenario: Rendering inline js with the feature enabled
    Given "minify_javascript" feature is "enabled"
    When I go to "/inline-js.html"
    Then I should see "1" lines