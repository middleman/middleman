Feature: Generator
  In order to generate static assets for client

  Scenario: Copying template files
    Given a project at "generator-test"
    And the project has been initialized
    Then template files should exist
    And empty directories should exist