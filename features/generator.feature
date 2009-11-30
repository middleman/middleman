Feature: Generator
  In order to generate static assets for client

  Scenario: Copying template files
    Given generated directory at "generator-test"
    Then template files should exist at "generator-test"
    And empty directories should exist at "generator-test"
    And cleanup at "generator-test"