Feature: Preview Lang Map
  In order to preview localized html
  
  Scenario: EN should be at root
    Given the Server is running at "name-map-app"
    When I go to "/"
    Then I should see "Howdy"

  Scenario: EN should be at root 2
    Given the Server is running at "name-map-app"
    When I go to "/index.html"
    Then I should see "Howdy"
    
  Scenario: EN mounted at root should not be in directory
    Given the Server is running at "name-map-app"
    When I go to "/english/index.html"
    Then I should see "File Not Found"
    
  Scenario: Paths can be localized EN
    Given the Server is running at "name-map-app"
    When I go to "/hello.html"
    Then I should see "Hello World"
    
  Scenario: ES should be under namespace
    Given the Server is running at "name-map-app"
    When I go to "/spanish/"
    Then I should see "Como Esta?"
    
  Scenario: ES should be under namespace 2
    Given the Server is running at "name-map-app"
    When I go to "/spanish/index.html"
    Then I should see "Como Esta?"
    
  Scenario: Paths can be localized ES
    Given the Server is running at "name-map-app"
    When I go to "/spanish/hola.html"
    Then I should see "Hola World"