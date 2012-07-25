Feature: Support coffee-script
  In order to offer an alternative when writing Javascript

  Scenario: Rendering coffee script
    Given the Server is running at "coffeescript-app"
    When I go to "/javascripts/coffee_test.js"
    Then I should see ".slice"

  Scenario: Rendering coffee-script with :coffeescript haml-filter
    Given the Server is running at "coffeescript-app"
    When I go to "/inline-coffeescript.html"
    Then I should see ".slice"
  
  Scenario: Rendering broken coffee
    Given the Server is running at "coffeescript-app"
    When I go to "/javascripts/broken-coffee.js"
    Then I should see "reserved word"
  
  Scenario: Building broken coffee
    Given a built app at "coffeescript-app"
    Then the output should contain "error  build/javascripts/broken-coffee.js"
    And the exit status should be 1