Feature: Sprockets Gems
  Scenario: Sprockets can pull jQuery from gem
    Given the Server is running at "sprockets-app"
    When I go to "/library/javascripts/jquery_include.js"
    Then I should see "var jQuery ="