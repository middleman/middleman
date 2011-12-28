Feature: CSS and Javascripts which are minify shouldn't be re-minified
  Scenario: CSS file
  
  Scenario: JS files containing ".min" should not be re-compressed
    And the Server is running at "already-minified-app"
    When I go to "/javascripts/test.min.js"
    Then I should see "10" lines
    
  Scenario: CSS files containing ".min" should not be re-compressed
    And the Server is running at "already-minified-app"
    When I go to "/stylesheets/test.min.css"
    Then I should see "10" lines