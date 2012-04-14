Feature: Builder Subset
  In order to preview localized html
  
  Scenario: EN should be at root
    Given a built app at "subset-app"
    Then "index.html" should exist at "subset-app" and include "Howdy"
    
  Scenario: EN mounted at root should not be in directory
    Given a built app at "subset-app"
    Then "en/index.html" should not exist at "subset-app"
    
  Scenario: Paths can be localized EN
    Given a built app at "subset-app"
    Then "hello.html" should exist at "subset-app" and include "Hello World"
    
  Scenario: ES should be under namespace
    Given a built app at "subset-app"
    Then "es/index.html" should not exist at "subset-app"
    
  Scenario: Paths can be localized ES
    Given a built app at "subset-app"
    Then "es/hola.html" should not exist at "subset-app"
