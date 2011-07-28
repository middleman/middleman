@wip
Feature: Tiny Src
  In order automatically scale images for mobile devices
    
  Scenario: Rendering html with the feature disabled
    Given "tiny_src" feature is "disabled"
    And the Server is running at "test-app"
    When I go to "/tiny_src.html"
    Then I should see "http://test.com/image.jpg"

  Scenario: Rendering html with the feature enabled
    Given "tiny_src" feature is "enabled"
    And the Server is running at "test-app"
    When I go to "/tiny_src.html"
    Then I should see "http://i.tinysrc.mobi/http://test.com/image.jpg"