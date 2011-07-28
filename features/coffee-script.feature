Feature: Support coffee-script
  In order to offer an alternative when writing Javascript

  Scenario: Rendering coffee script
    Given the Server is running at "test-app"
    When I go to "/javascripts/coffee_test.js"
    Then I should see "Array.prototype.slice"

  Scenario: Rendering coffee-script with :coffeescript haml-filter
    Given the Server is running at "test-app"
    When I go to "/inline-coffeescript.html"
    Then I should see "Array.prototype.slice"
  
  Scenario: Rendering broken coffee
    Given the Server is running at "test-app"
    When I go to "/javascripts/broken-coffee.js"
    Then I should see "Reserved word"