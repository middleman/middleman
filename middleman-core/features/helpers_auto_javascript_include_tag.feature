Feature: Built-in auto_javascript_include_tag view helper
  In order to simplify including javascript files

  Scenario: Viewing the root path
    Given the Server is running at "auto-js-app"
    When I go to "/auto-js.html"
    Then I should see "javascripts/auto-js.js"

  Scenario: Viewing a tier-1 path
    Given the Server is running at "auto-js-app"
    When I go to "/auto-js/auto-js.html"
    Then I should see "javascripts/auto-js/auto-js.js"

  Scenario: Viewing the index file of a tier-1 path, without filename
    Given the Server is running at "auto-js-app"
    When I go to "/auto-js"
    Then I should see "javascripts/auto-js/index.js"

  Scenario: Viewing the index file of a tier-1 path, without filename, with a trailing slash
    Given the Server is running at "auto-js-app"
    When I go to "/auto-js/"
    Then I should see "javascripts/auto-js/index.js"

  Scenario: Viewing a tier-2 path
    Given the Server is running at "auto-js-app"
    When I go to "/auto-js/sub/auto-js.html"
    Then I should see "javascripts/auto-js/sub/auto-js.js"
