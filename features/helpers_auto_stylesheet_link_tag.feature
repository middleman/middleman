Feature: Built-in auto_stylesheet_link_tag view helper
  In order to simplify including css files

  Scenario: Viewing the root path
    Given the Server is running
    When I go to "/auto-css.html"
    Then I should see "stylesheets/auto-css.css"

  Scenario: Viewing a tier-1 path
    Given the Server is running
    When I go to "/sub1/auto-css.html"
    Then I should see "stylesheets/sub1/auto-css.css"

  Scenario: Viewing a tier-2 path
    Given the Server is running
    When I go to "/sub1/sub2/auto-css.html"
    Then I should see "stylesheets/sub1/sub2/auto-css.css"