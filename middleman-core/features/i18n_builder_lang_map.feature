@wip
Feature: Builder Lang Map
  In order to preview localized html
  
  Scenario: EN should be at root
    Given a built app at "name-map-app"
    Then "index.html" should exist at "name-map-app" and include "Howdy"
    
  Scenario: EN mounted at root should not be in directory
    Given a built app at "name-map-app"
    Then "english/index.html" should not exist at "name-map-app"
    
  Scenario: Paths can be localized EN
    Given a built app at "name-map-app"
    Then "hello.html" should exist at "name-map-app" and include "Hello World"
    
  Scenario: ES should be under namespace
    Given a built app at "name-map-app"
    Then "spanish/index.html" should exist at "name-map-app" and include "Como Esta?"
    
  Scenario: Paths can be localized ES
    Given a built app at "name-map-app"
    Then "spanish/hola.html" should exist at "name-map-app" and include "Hola World"
