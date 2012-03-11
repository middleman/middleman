@wip
Feature: Builder Alt Root
  In order to preview localized html
  
  Scenario: EN should be at root
    Given a built app at "alt-root-app"
    Then "index.html" should exist at "alt-root-app" and include "Howdy"
    
  Scenario: EN mounted at root should not be in directory
    Given a built app at "alt-root-app"
    Then "en/index.html" should not exist at "alt-root-app"
    
  Scenario: Paths can be localized EN
    Given a built app at "alt-root-app"
    Then "hello.html" should exist at "alt-root-app" and include "Hello World"
    
  Scenario: ES should be under namespace
    Given a built app at "alt-root-app"
    Then "es/index.html" should exist at "alt-root-app" and include "Como Esta?"
    
  Scenario: Paths can be localized ES
    Given a built app at "alt-root-app"
    Then "es/hola.html" should exist at "alt-root-app" and include "Hola World"
