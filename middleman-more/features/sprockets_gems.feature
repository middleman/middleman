Feature: Sprockets Gems
  Scenario: Sprockets can pull jQuery from gem
    Given the Server is running at "sprockets-app"
    When I go to "/library/js/jquery_include.js"
    Then I should see "var jQuery ="
  
  # Scenario: Sprockets can pull CSS from gem
  #   Given the Server is running at "sprockets-app"
  #   When I go to "/library/css/bootstrap_include.css"
  #   Then I should see "Bootstrap"
  
  Scenario: Sprockets can pull js from vendored assets
    Given the Server is running at "sprockets-app"
    When I go to "/library/js/vendored_include.js"
    Then I should see "var vendored_js_included = true;"