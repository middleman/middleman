@wip
Feature: Builder Alt Path
  In order to preview localized html
  
  Scenario: EN should be at root
    Given a successfully built app at "alt-path-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html                                    |
    And the file "index.html" should contain "Howdy"
    
  Scenario: EN mounted at root should not be in directory
    Given a successfully built app at "alt-path-app"
    When I cd to "build"
    Then the following files should not exist:
      | lang_en/index.html                                   |
    
  Scenario: Paths can be localized EN
    Given a successfully built app at "alt-path-app"
    When I cd to "build"
    Then the following files should exist:
      | hello.html                                    |
    And the file "hello.html" should contain "Hello World"
    
  Scenario: ES should be under namespace
    Given a successfully built app at "alt-path-app"
    When I cd to "build"
    Then the following files should exist:
      | lang_es/index.html                                    |
    And the file "lang_es/index.html" should contain "Como Esta?"
    
  Scenario: Paths can be localized ES
    Given a successfully built app at "alt-path-app"
    When I cd to "build"
    Then the following files should exist:
      | lang_es/hola.html                                    |
    And the file "lang_es/hola.html" should contain "Hola World"
