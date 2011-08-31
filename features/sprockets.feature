Feature: Sprockets

  Scenario: Sprockets require
    Given the Server is running at "test-app"
    When I go to "/javascripts/sprockets_base.js"
    Then I should see "sprockets_sub_function"
    
  Scenario: Sprockets require with custom :js_dir
    Given the Server is running at "sprockets-app"
    When I go to "/library/javascripts/sprockets_base.js"
    Then I should see "sprockets_sub_function"
    
  Scenario: Sprockets should have access to yaml data
    Given the Server is running at "test-app"
    When I go to "/javascripts/multiple_engines.js"
    Then I should see "Hello One"
    
  Scenario: Multiple engine files should build correctly
    Given a built app at "test-app"
    Then "javascripts/multiple_engines.js" should exist at "test-app" and include "Hello One"
    And cleanup built app at "test-app"