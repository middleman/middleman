Feature: Preview No Mount
  In order to preview localized html
  
  Scenario: EN should be at root
    Given the Server is running at "no-mount-app"
    When I go to "/en/"
    Then I should see "Howdy"

  Scenario: EN should be at root 2
    Given the Server is running at "no-mount-app"
    When I go to "/en/index.html"
    Then I should see "Howdy"
    
  Scenario: EN mounted at root should not be in directory
    Given the Server is running at "no-mount-app"
    When I go to "/index.html"
    Then I should see "File Not Found"
    
  Scenario: Paths can be localized EN
    Given the Server is running at "no-mount-app"
    When I go to "/en/hello.html"
    Then I should see "Hello World"
    
  Scenario: ES should be under namespace
    Given the Server is running at "no-mount-app"
    When I go to "/es/"
    Then I should see "Como Esta?"
    
  Scenario: ES should be under namespace 2
    Given the Server is running at "no-mount-app"
    When I go to "/es/index.html"
    Then I should see "Como Esta?"
    
  Scenario: Paths can be localized ES
    Given the Server is running at "no-mount-app"
    When I go to "/es/hola.html"
    Then I should see "Hola World"