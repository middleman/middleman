Feature: Support coffee-script
  In order to offer an alternative when writing Javascript
  
  Scenario: Rendering coffee script
    Given the Server is running
    When I go to "/javascripts/coffee_test.js"
    Then I should see "Array.prototype.slice"