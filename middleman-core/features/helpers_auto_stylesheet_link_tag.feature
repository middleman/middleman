Feature: Built-in auto_stylesheet_link_tag view helper
  In order to simplify including css files

  Scenario: Viewing the root path
    Given the Server is running at "auto-css-app"
    When I go to "/auto-css.html"
    Then I should see "stylesheets/auto-css.css"

  Scenario: Viewing a tier-1 path
    Given the Server is running at "auto-css-app"
    When I go to "/auto-css/auto-css.html"
    Then I should see "stylesheets/auto-css/auto-css.css"

  Scenario: Viewing the index file of a tier-1 path, without filename
    Given the Server is running at "auto-css-app"
    When I go to "/auto-css"
    Then I should see "stylesheets/auto-css/index.css"

  Scenario: Viewing the index file of a tier-1 path, without filename, with a trailing slash
    Given the Server is running at "auto-css-app"
    When I go to "/auto-css/"
    Then I should see "stylesheets/auto-css/index.css"

  Scenario: Viewing a tier-2 path
    Given the Server is running at "auto-css-app"
    When I go to "/auto-css/sub/auto-css.html"
    Then I should see "stylesheets/auto-css/sub/auto-css.css"
