Feature: Sprockets

  Scenario: Sprockets JS require
    Given the Server is running at "sprockets-app2"
    When I go to "/javascripts/sprockets_base.js"
    Then I should see "sprockets_sub_function"
    
  Scenario: Sprockets JS require with custom :js_dir
    Given the Server is running at "sprockets-app"
    When I go to "/library/js/sprockets_base.js"
    Then I should see "sprockets_sub_function"
    
  Scenario: Plain JS require with custom :js_dir
    Given the Server is running at "sprockets-app"
    When I go to "/library/css/plain.css"
    Then I should see "helloWorld"
    
  Scenario: Sprockets JS should have access to yaml data
    Given the Server is running at "sprockets-app2"
    When I go to "/javascripts/multiple_engines.js"
    Then I should see "Hello One"
    
  Scenario: Multiple engine files should build correctly
    Given a successfully built app at "sprockets-app2"
    When I cd to "build"
    Then a file named "javascripts/multiple_engines.js" should exist
    And the file "javascripts/multiple_engines.js" should contain "Hello One"
  
  Scenario: Sprockets CSS require //require
    Given the Server is running at "sprockets-app2"
    When I go to "/stylesheets/sprockets_base1.css"
    Then I should see "hello"
    
  Scenario: Sprockets CSS require @import
    Given the Server is running at "sprockets-app2"
    When I go to "/stylesheets/sprockets_base2.css"
    Then I should see "hello"

  Scenario: Sprockets CSS require with custom :css_dir //require
    Given the Server is running at "sprockets-app"
    When I go to "/library/css/sprockets_base1.css"
    Then I should see "hello"
    
  Scenario: Plain CSS require with custom :css_dir
    Given the Server is running at "sprockets-app"
    When I go to "/library/css/plain.css"
    Then I should see "helloWorld"
    
  Scenario: Sprockets CSS require with custom :css_dir @import
    Given the Server is running at "sprockets-app"
    When I go to "/library/css/sprockets_base2.css"
    Then I should see "hello"