Feature: Sprockets

  Scenario: Sprockets JS require
    Given the Server is running at "test-app"
    When I go to "/javascripts/sprockets_base.js"
    Then I should see "sprockets_sub_function"
    
  Scenario: Sprockets JS require with custom :js_dir
    Given the Server is running at "sprockets-app"
    When I go to "/library/javascripts/sprockets_base.js"
    Then I should see "sprockets_sub_function"
    
  Scenario: Sprockets JS should have access to yaml data
    Given the Server is running at "test-app"
    When I go to "/javascripts/multiple_engines.js"
    Then I should see "Hello One"
    
  Scenario: Multiple engine files should build correctly
    Given a built app at "test-app"
    Then "javascripts/multiple_engines.js" should exist at "test-app" and include "Hello One"
    And cleanup built app at "test-app"
  
  Scenario: Sprockets CSS require //require
    Given the Server is running at "test-app"
    When I go to "/stylesheets/sprockets_base1.css"
    Then I should see "hello"
    
  Scenario: Sprockets CSS require @import
    Given the Server is running at "test-app"
    When I go to "/stylesheets/sprockets_base2.css"
    Then I should see "hello"

  Scenario: Sprockets CSS require with custom :css_dir //require
    Given the Server is running at "sprockets-app"
    When I go to "/library/stylesheets/sprockets_base1.css"
    Then I should see "hello"
    
  Scenario: Sprockets CSS require with custom :css_dir @import
    Given the Server is running at "sprockets-app"
    When I go to "/library/stylesheets/sprockets_base2.css"
    Then I should see "hello"